# Spleeter Docker Wrapper

This is a simple bash script to call and use the docker image for [Spleeter](https://github.com/deezer/spleeter).

## Installation

First step is to clone this script:

```bash
git clone https://github.com/henrywhitaker3/spleeter-docker-wrapper
```

You can now go into this folder and use the script with:

```bash
bash spleeter.sh [options]
```

If you want to install the script (make a copy of the script and set an alias), you can run:

```bash
bash spleeter.sh -i
```

You should now be able to run this script by using:

```bash
spleterd [options]
```

## Usage

This command will split audio into instrumental and vocals:

```bash
spleeterd -f test.mp3"
```

Specify how many stems to split the audio into with `-s` or `--stems`:

```bash
spleeterd -f test.mp3 -s 5"
```

Specify the cutoff in kHz with `-c` or `--cutoff`:

```bash
spleeterd -f test.mp3 -c 16"
```

You can see more options with `-h` or `--help`:

```bash
spleterd -h
```