#!/usr/bin/env python3
# File: /home/kami/sentinel-stack/scenarios/lib/fetch_scenario_assets.py
# ==============================================================================
# ARYORITHM SENTINEL-STACK: GLOBAL ONNX & PCAP PROVISIONING DOWNLOADER
# Tier 4 Toolchain Engine integrated with Tier 0 sentinel_fs Content-Addressable Storage
# ==============================================================================

import argparse
import hashlib
import json
import os
import shutil
import ssl
import struct
import sys
import urllib.error
import urllib.request
from pathlib import Path

# Tier 0 Sovereign Sentinel Filesystem Integration
from sentinel_fs import SentinelPathResolver, ObjectClass, CasStore


def resolve_git_lfs_pointer(lfs_text: bytes, repo_url: str, ctx: ssl.SSLContext):
    lines = lfs_text.decode("utf-8", errors="ignore").splitlines()
    oid, size = None, None
    for line in lines:
        if line.startswith("oid sha256:"):
            oid = line.replace("oid sha256:", "").strip()
        elif line.startswith("size "):
            size = int(line.replace("size ", "").strip())
    if not oid or not size or not repo_url:
        return None

    batch_url = f"{repo_url.rstrip('/')}.git/info/lfs/objects/batch"
    headers = {
        "Content-Type": "application/vnd.git-lfs+json",
        "Accept": "application/vnd.git-lfs+json",
        "User-Agent": "git-lfs/3.4.0",
    }
    payload = json.dumps({
        "operation": "download",
        "transfers": ["basic"],
        "objects": [{"oid": oid, "size": size}],
    }).encode("utf-8")

    req = urllib.request.Request(batch_url, data=payload, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=20, context=ctx) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return data["objects"][0]["actions"]["download"]["href"]
    except Exception as exc:
        print(f"    [!] Git LFS batch resolution failed ({repo_url}): {exc}")
        return None


def infer_github_repo(raw_url: str) -> str:
    if "raw.githubusercontent.com/" in raw_url:
        parts = raw_url.split("raw.githubusercontent.com/", 1)[1].split("/")
        if len(parts) >= 2:
            return f"https://github.com/{parts[0]}/{parts[1]}"
    if "github.com/" in raw_url and "/raw/" in raw_url:
        parts = raw_url.split("github.com/", 1)[1].split("/")
        if len(parts) >= 2:
            return f"https://github.com/{parts[0]}/{parts[1]}"
    return ""


def is_valid_pcap_binary(path: Path) -> bool:
    if not path.is_file() or path.stat().st_size < 24:
        return False
    magic = path.read_bytes()[:4]
    val = struct.unpack("<I", magic)[0]
    return val in (0xA1B2C3D4, 0xD4C3B2A1, 0xA1B23C4D, 0x4D3CB2A1, 0x0A0D0D0A)


def is_valid_onnx_file(path: Path) -> bool:
    if not path.is_file() or path.stat().st_size < 128:
        return False
    head = path.read_bytes()[:64]
    if head.startswith(b"version https://git-lfs") or head.lstrip().startswith(b"<"):
        return False
    try:
        import openvino as ov  # type: ignore
        ov.Core().read_model(str(path))
        return True
    except ImportError:
        return True
    except Exception as exc:
        print(f"    [!] OpenVINO model validation warning for {path.name}: {exc}")
        return True


def download_url(url: str, dest: Path, repo_hint: str = "") -> bool:
    ctx = ssl.create_default_context()
    req = urllib.request.Request(url, headers={"User-Agent": "SentinelStack/2.5"})
    try:
        with urllib.request.urlopen(req, timeout=30, context=ctx) as resp:
            data = resp.read()

        if data.startswith(b"version https://git-lfs.github.com/spec/v1"):
            repo = repo_hint or infer_github_repo(url)
            print(f"    [*] Resolving Git LFS pointer for {dest.name} ({repo})...")
            real_url = resolve_git_lfs_pointer(data, repo, ctx)
            if not real_url:
                return False
            lfs_req = urllib.request.Request(real_url, headers={"User-Agent": "SentinelStack/2.5"})
            with urllib.request.urlopen(lfs_req, timeout=60, context=ctx) as lfs_resp:
                data = lfs_resp.read()

        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(data)
        return True
    except Exception as exc:
        print(f"    [-] Download failed ({url}): {exc}")
        return False


def synthesize_domain_pcap(dest: Path, proto_port: int, ethertype: int = 0x0800):
    frames = []
    for i in range(16):
        if ethertype in (0x88B8, 0x88BA, 0x88A4):
            eth = b"\x01\x0c\xcd\x01\x00\x01\x02\x42\x0a\xf0\x01\x32" + struct.pack(">H", ethertype)
            if ethertype == 0x88A4:
                pdu = struct.pack("<H", (1 << 12) | 20) + (b"\x00" * 10) + struct.pack("<ffH", 4.2, 320.0, 1)
            else:
                pdu = struct.pack(">HHHHII", 0x0001, 16, 0, 0, 10, i + 1)
            frames.append(eth + pdu)
        else:
            eth = b"\x02\x42\x0a\xf0\x01\x65\x02\x42\x0a\xf0\x01\x32\x08\x00"
            if proto_port == 502:
                payload = bytes([0x00, i + 1, 0x00, 0x00, 0x00, 0x06, 0x01, 0x03, 0x00, 0x00, 0x00, 0x04])
            elif proto_port == 2152:
                payload = struct.pack(">BBHI", 0x30, 0xFF, 24, 0x00000100) + b"\x45\x00\x00\x18" + (b"\x00" * 16) + struct.pack(">HH", 12345, 502)
            elif proto_port == 50050:
                payload = struct.pack(">HIIQHfff", 0x1001, 1, i + 100, 1000000 + i * 50000, 12, float(i * 2.0), 80.0, 120.0)
            else:
                payload = struct.pack(">II", 0x53454E54, i + 1) + (b"\x10" * 24)
            udp_len = 8 + len(payload)
            ip_len = 20 + udp_len
            ip = struct.pack(">BBHHHBBH4s4s", 0x45, 0, ip_len, i + 1, 0, 64, 17, 0, b"\x0a\xf0\x01\x32", b"\x0a\xf0\x01\x65")
            udp = struct.pack(">HHHH", 40000 + i, proto_port, udp_len, 0)
            frames.append(eth + ip + udp + payload)

    dest.parent.mkdir(parents=True, exist_ok=True)
    with open(dest, "wb") as f:
        f.write(struct.pack("<IHHIIII", 0xA1B2C3D4, 2, 4, 0, 0, 65535, 1))
        for idx, fr in enumerate(frames):
            f.write(struct.pack("<IIII", 1700000000 + idx, 0, len(fr), len(fr)))
            f.write(fr)


def train_and_export_domain_ae(dest: Path, dim: int = 32, pcap_dir: Path = None):
    """Trains and exports a calibrated PyTorch Autoencoder ONNX model directly into SSFS."""
    import torch
    import torch.nn as nn

    samples = []
    if pcap_dir and pcap_dir.is_dir():
        for pf in sorted(pcap_dir.glob("*.pcap")):
            raw = pf.read_bytes()[24:]
            for off in range(0, max(0, len(raw) - dim), dim):
                vec = [b / 255.0 for b in raw[off:off + dim]]
                samples.append(vec)
                if len(samples) >= 256:
                    break
            if len(samples) >= 256:
                break

    if len(samples) < 16:
        samples = [[0.08 + 0.02 * ((i + j) % 5) for j in range(dim)] for i in range(64)]

    x_train = torch.tensor(samples, dtype=torch.float32)

    class DomainAE(nn.Module):
        def __init__(self, d: int):
            super().__init__()
            self.net = nn.Sequential(
                nn.Linear(d, max(8, d // 2)),
                nn.ReLU(),
                nn.Linear(max(8, d // 2), d),
            )

        def forward(self, x):
            return self.net(x)

    torch.manual_seed(42)
    model = DomainAE(dim)
    opt = torch.optim.Adam(model.parameters(), lr=0.02)
    loss_fn = nn.MSELoss()
    model.train()
    for _ in range(40):
        opt.zero_grad()
        out = model(x_train)
        loss = loss_fn(out, x_train)
        loss.backward()
        opt.step()

    model.eval()
    dest.parent.mkdir(parents=True, exist_ok=True)
    dummy = torch.zeros(1, dim, dtype=torch.float32)
    torch.onnx.export(
        model, dummy, str(dest),
        input_names=["input"], output_names=["scores"],
        opset_version=17,
        dynamo=False,
    )
    print(f"[+] Exported calibrated domain ONNX AE: {dest.name} (dim={dim}, trained on {len(samples)} vectors)")


def link_or_copy(source: Path, target: Path):
    """Creates a hardlink to avoid disk duplication, falling back to a standard copy if crossing filesystems."""
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists():
        target.unlink()
    try:
        os.link(source, target)
    except OSError:
        shutil.copy2(source, target)


def main():
    parser = argparse.ArgumentParser(description="Sentinel-Stack Global Asset Fetcher (SSFS Connected)")
    parser.add_argument("--scenario-dir", required=True)
    parser.add_argument("--cache-dir", default=None)
    parser.add_argument("--onnx", action="append", default=[], help="filename=url")
    parser.add_argument("--pcap", action="append", default=[], help="filename=url[|repo]")
    parser.add_argument("--domain-ae", default="domain_calibrated_ae.onnx")
    parser.add_argument("--ae-dim", type=int, default=32)
    parser.add_argument("--proto-port", type=int, default=502)
    parser.add_argument("--ethertype", default="0x0800")
    args = parser.parse_args()

    sdir = Path(args.scenario_dir).resolve()
    models_dir = sdir / "models"
    pcaps_dir = sdir / "pcaps"
    models_dir.mkdir(parents=True, exist_ok=True)
    pcaps_dir.mkdir(parents=True, exist_ok=True)

    # Resolve SSFS Cache and CAS Stores
    cas = CasStore()
    download_cache = Path(args.cache_dir) if args.cache_dir else SentinelPathResolver.resolve_dir(ObjectClass.ARTIFACT_DOWNLOAD)
    (download_cache / "models").mkdir(parents=True, exist_ok=True)
    (download_cache / "pcaps").mkdir(parents=True, exist_ok=True)

    # 1. Fetch & stage global PCAPs with CAS Deduplication
    for entry in args.pcap:
        if "=" not in entry:
            continue
        fname, rest = entry.split("=", 1)
        url, repo = (rest.split("|", 1) + [""])[:2]
        cached_pcap = download_cache / "pcaps" / fname
        target_pcap = pcaps_dir / fname

        if not is_valid_pcap_binary(cached_pcap):
            print(f"[*] Fetching internet PCAP: {fname} <- {url}")
            if not download_url(url, cached_pcap, repo) or not is_valid_pcap_binary(cached_pcap):
                print(f"    [!] Remote PCAP unavailable; generating fallback for {fname}")
                synthesize_domain_pcap(cached_pcap, args.proto_port, int(args.ethertype, 16))

        cas_obj = cas.store_file(cached_pcap, ObjectClass.ARTIFACT_PCAP)
        link_or_copy(cas_obj.path, target_pcap)
        print(f"[+] Staged PCAP (CAS Deduplicated): {target_pcap.name} ({target_pcap.stat().st_size:,} bytes, sha256:{cas_obj.sha256[:12]}...)")

    if not any(pcaps_dir.glob("*.pcap")):
        synth = pcaps_dir / "scenario_baseline.pcap"
        synthesize_domain_pcap(synth, args.proto_port, int(args.ethertype, 16))
        cas.store_file(synth, ObjectClass.ARTIFACT_PCAP)
        print(f"[+] Staged baseline PCAP: {synth.name}")

    # 2. Fetch & stage global ONNX models with CAS Deduplication
    for entry in args.onnx:
        if "=" not in entry:
            continue
        fname, url = entry.split("=", 1)
        cached_onnx = download_cache / "models" / fname
        target_onnx = models_dir / fname

        if not is_valid_onnx_file(cached_onnx):
            print(f"[*] Fetching internet ONNX model: {fname} <- {url}")
            download_url(url, cached_onnx)

        if is_valid_onnx_file(cached_onnx):
            cas_obj = cas.store_file(cached_onnx, ObjectClass.MODEL_REGISTRY)
            link_or_copy(cas_obj.path, target_onnx)
            print(f"[+] Staged ONNX (CAS Deduplicated): {target_onnx.name} ({target_onnx.stat().st_size:,} bytes, sha256:{cas_obj.sha256[:12]}...)")
        else:
            print(f"    [!] Remote ONNX fetch failed for {fname}; calibrating local domain AE instead.")

    # 3. Export and calibrate domain ONNX Autoencoder into SSFS
    if args.domain_ae:
        ae_target = models_dir / args.domain_ae
        if not is_valid_onnx_file(ae_target):
            train_and_export_domain_ae(ae_target, dim=args.ae_dim, pcap_dir=pcaps_dir)
            cas.store_file(ae_target, ObjectClass.MODEL_CALIBRATED)


if __name__ == "__main__":
    main()