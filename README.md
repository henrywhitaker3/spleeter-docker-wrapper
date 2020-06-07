# Spleeter Docker Wrapper

This is a simple bash script to call and use the docker image for [spleeter](https://github.com/deezer/spleeter).

## Installation

First step is to clone this script:

```bash
git clone https://github.com/henrywhitaker3/spleeter-docker-wrapper.git
```

You can now go into this folder and use the script with:

```bash
bash spleeter.sh [options]
```

If you want to install the script (make a copy of the script and set an alias), you can run:

```bash
bash spleeter.sh -i
```

You should now be able to delete the cloned folder and run this script by using:

```bash
spleeterd [options]
```

## Usage

To use this script you need to have access to run docker commands.

This command will split audio into instrumental and vocals:

```bash
spleeterd -f test.mp3
```

Specify how many stems to split the audio into with `-s` or `--stems`:

```bash
spleeterd -f test.mp3 -s 5
```

Specify the cutoff in kHz with `-c` or `--cutoff`:

```bash
spleeterd -f test.mp3 -c 16
```

You can see more options with `-h` or `--help`:

```bash
spleeterd -h
```