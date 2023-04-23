import os
from io import StringIO
import urllib.parse
from collections import defaultdict


nix_system_to_platform_tag = {
    "x86_64-linux": "linux_x86_64",
    "x86_64-darwin": "macosx_10_9_x86_64",
    "aarch64-darwin": "macosx_11_0_arm64",
}

default_cuda_version = "cu118"
cpu = "cpu"
default_torch_version = "2.0.0"
default_torchtriton_version = "2.0.0"
default_torchvision_version = "0.15.1"
default_torchtext_version = "0.15.1"
default_torchaudio_version = "2.0.1"
default_torchdata_version = "0.6.0"

# supported_python_versions = ["38", "39", "310", "311"]
supported_python_versions = ["310"]

packages = {
    "torch": [
        ("x86_64-linux", default_torch_version, default_cuda_version),
        ("x86_64-darwin", default_torch_version, None),
        ("aarch64-darwin", default_torch_version, None),
    ],
    "triton": [
        ("x86_64-linux", default_torchtriton_version, None),
    ],
    "torchvision": [
        ("x86_64-linux", default_torchvision_version, default_cuda_version),
        ("x86_64-darwin", default_torchvision_version, None),
        ("aarch64-darwin", default_torchvision_version, None),
    ],
    "torchtext": [
        ("x86_64-linux", default_torchtext_version, cpu),
        ("x86_64-darwin", default_torchtext_version, None),
        ("aarch64-darwin", default_torchtext_version, None),
    ],
    "torchaudio": [
        ("x86_64-linux", default_torchaudio_version, default_cuda_version),
        ("x86_64-darwin", default_torchaudio_version, None),
        ("aarch64-darwin", default_torchaudio_version, None),
    ],
    "torchdata": [
        ("x86_64-linux", default_torchdata_version, None),
        ("x86_64-darwin", default_torchdata_version, None),
        ("aarch64-darwin", default_torchdata_version, None),
    ],
}


def to_python_tag(nix_python_version):
    return f"cp{nix_python_version}"


def get_default_abi_tag(package_name, python_tag, platform_tag):
    if "linux" not in platform_tag and package_name == "torch":
        return "none"

    abi_tag = python_tag
    if abi_tag == "cp37":
        return "cp37m"
    else:
        return python_tag


def get_wheel_url(
    package_name,
    version,
    python_tag,
    platform_tag,
    abi_tag=None,
    cuda_version=None,
):
    if cuda_version is None or cuda_version == "cpu":
        if (
            (package_name in ("triton", "torchtext") and "linux" in platform_tag)
            or package_name == "torchdata"
            or (package_name == "torchaudio" and "macosx" not in platform_tag)
        ):
            base_url = "https://download.pytorch.org/whl"
        else:
            base_url = "https://download.pytorch.org/whl/cpu"
    else:
        base_url = f"https://download.pytorch.org/whl/{cuda_version}"

    cuda_suffix = f"+{cuda_version}" if cuda_version else ""

    if abi_tag is None:
        abi_tag = get_default_abi_tag(package_name, python_tag, platform_tag)

    file_path = urllib.parse.quote(
        f"{package_name}-{version}{cuda_suffix}-{python_tag}-{abi_tag}-{platform_tag}.whl"
    )

    return f"{base_url}/{file_path}"


def get_torch_wheel_name(
    package_name,
    version,
    python_tag,
    platform_tag,
    abi_tag=None,
):
    if abi_tag is None:
        abi_tag = get_default_abi_tag(package_name, python_tag, platform_tag)

    return f"{package_name}-{version}-{python_tag}-{abi_tag}-{platform_tag}.whl"


def get_url_hash(url, name):
    raw_hash = os.popen(f'nix-prefetch-url "{url}" --name "{name}"').read().strip()
    return os.popen(f"nix hash to-sri --type sha256 {raw_hash}").read().strip()


def generate_variant_entry(key, name, url, hash):
    return f"""      {key} = {{
        name = "{name}";
        url = "{url}";
        hash = "{hash}";
      }};"""


def generate_section_for_package(package_name, variants):
    result = StringIO()
    entries_by_version = defaultdict(list)

    for nix_system, package_version, cuda_version in variants:
        for nix_python_version in supported_python_versions:
            platform_tag = nix_system_to_platform_tag[nix_system]
            if package_name in ("torchdata", "triton"):
                if "linux_x86_64" in platform_tag:
                    platform_tag = "manylinux_2_17_x86_64.manylinux2014_x86_64"
                if platform_tag == "macosx_10_9_x86_64":
                    platform_tag = "macosx_10_13_x86_64"

            python_tag = to_python_tag(nix_python_version)

            wheel_url = get_wheel_url(
                package_name,
                package_version,
                python_tag,
                platform_tag,
                cuda_version=cuda_version,
            )
            wheel_name = get_torch_wheel_name(
                package_name,
                package_version,
                python_tag,
                platform_tag,
            )
            url_hash = get_url_hash(wheel_url, wheel_name)

            entries_by_version[package_version].append(
                generate_variant_entry(
                    f"{nix_system}-{nix_python_version}",
                    wheel_name,
                    wheel_url,
                    url_hash,
                )
            )

    for version, entries in entries_by_version.items():
        content = "\n".join(entries)
        result.write(
            f"""    "{version}" = {{
{content}
    }};"""
        )

    return result.getvalue()


def generate_binary_hashes():
    result = StringIO()
    result.write(
        """
# generated by pkgs/torch/prefetch.py

package: version: builtins.getAttr version (builtins.getAttr package {""".lstrip()
    )

    for package_name, variants in packages.items():
        result.write(
            f"""
  {package_name} = {{
{generate_section_for_package(package_name, variants)}
  }};
"""
        )

    result.write("})\n")

    return result.getvalue()


if __name__ == "__main__":
    current_dir = os.path.dirname(__file__)
    content = generate_binary_hashes()
    with open(os.path.join(current_dir, "binary-hashes.nix"), "w") as f:
        f.write(content)
