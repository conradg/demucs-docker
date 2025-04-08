# Demucs Docker Container

A Docker container for running Facebook's Demucs audio separation model. This container makes it easy to separate audio tracks into their individual components (vocals, drums, bass, and other instruments).

## Installation

### Quick Setup (Recommended)

1. Clone this repository:
```bash
git clone https://github.com/conradg/demucs-docker.git
cd demucs-docker
```

2. Run the setup script:
```bash
./setup.sh
```

3. Restart your terminal or run:
```bash
source ~/.bashrc  # for bash
# or
source ~/.zshrc   # for zsh
```

After setup, you can use the `demucs` command from anywhere:
```bash
demucs --input your-song.mp3
```

### Manual Installation

If you prefer to set up manually, you can run the container directly:

```bash
docker run -v $(pwd):/data conradgodfrey/demucs:latest --input /data/your-song.mp3
```

## Quick Start

```bash
docker run -v $(pwd):/data conradgodfrey/demucs:latest --input /data/your-song.mp3
```

## Usage

The container accepts the following arguments:

- `--input` or `-i`: Path to the input audio file (required)
- `--output` or `-o`: Path to the output directory (optional)

### Examples

1. Basic usage (output will be in the same directory as input):
```bash
docker run -v $(pwd):/data conradgodfrey/demucs:latest --input /data/your-song.mp3
```

2. Specify custom output directory:
```bash
docker run -v $(pwd):/data conradgodfrey/demucs:latest --input /data/your-song.mp3 --output /data/output
```

## Important Notes

1. The container needs access to your local filesystem to read input files and write output files. This is done using Docker volumes (`-v $(pwd):/data`).
2. Input and output paths should be relative to the mounted volume (`/data`).
3. If no output directory is specified, the container will create one in the same directory as the input file with the name `[input-filename] - split`.

## Output

The separated tracks will be saved in the specified output directory (or the default location) with the following structure:
- `vocals.wav`
- `drums.wav`
- `bass.wav`
- `other.wav`

## Requirements

- Docker installed on your system
- Sufficient disk space for the input and output files
- Sufficient RAM for audio processing (recommended: 8GB+) 