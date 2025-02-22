# AFL++ Trial with Google's Fuzzer Test Suite

This is a trial for running **AFL++** with **Google's Fuzzer Test Suite** to evaluate fuzzing performance and detect crashes.  

The focus is on analyzing how AFL++ performs on different test cases and identifying potential vulnerabilities.  

Crash analysis will be handled separately with a custom script.

# Prerequisites
- Docker

# Setup Instructions
- Build the included DockerFile and get into an interactive shell with: `sudo docker build -t AFL_trials .` then `docker run -it AFL_trials`

  

- You should now be inside the container

  

- Install a text editor (e.g. nano with `apt install -y nano`)

  

- Open the file `/app/fuzzer-test-suite/common.sh`, and replace the line:

  

  

```bash

FSANITIZE_FUZZER_FLAGS="-O2 -fno-omit-frame-pointer -gline-tables-only -fsanitize=address,fuzzer-no-link -fsanitize-address-use-after-scope"
```

  

  

- With:

  

  

```bash

FSANITIZE_FUZZER_FLAGS="-O2 -fno-omit-frame-pointer -gline-tables-only -fsanitize=fuzzer"
```

  

  

- Now `cd /app/build` and run `./build_program.sh`. This should create a directory for `vorbis-2017-12-11` and build the program.

  

- Try running the fuzzer on vorbis by running the following commands:

  

-  `cd vorbis-2017-12-11`

  

-  `mkdir seeds`

  

-  `cp /app/fuzzer-test-suite/vorbis-2017-12-11/seeds/* seeds/`

  

-  `afl-fuzz -i seeds/ -o OUT -- ./vorbis-2017-12-11-fsanitize_fuzzer`

  

- You should see a status screen that looks like this - check that the `exec speed` is above 100, and the `corpus count` is growing quickly.
  

- Provided the test with vorbis is working, you can now move on to your assigned target program. To do so, you must first `cd /app/build` , and now modify `build_program.sh` in order to replace the line `SUT=vorbis-2017-12-11` with `SUT=YOUR_TARGET_PROGRAM` (where `YOUR_TARGET_PROGRAM` is your assigned program). Finally, save the changes, and rerun `./build_program.sh`.

  

- You should now be able to `cd YOUR_TARGET_PROGRAM`, within there should be a binary with the name `YOUR_TARGET_PROGRAM-fsanitize_fuzzer` - this will be the binary that you fuzz test.

  

- If `/app/build/YOUR_TARGET_PROGRAM` does not contain a directory called `seeds`, then you will need to create it with `mkdir seeds` . If `/app/fuzzer-test-suite/YOUR_TARGET_PROGRAM/seeds` exists, then copy across the contents of that directory into the `seeds` directory you just made; otherwise you will need to create a simple seed with `echo AAAAA > seeds/in1`

  

- You can now begin fuzzing your program with the command `afl-fuzz -i seeds -o OUT -- ./YOUR_TARGET_PROGRAM-sanitize-fuzzer`. Again you should see a live status screen, as documented here: [https://aflplus.plus/docs/status_screen/](https://aflplus.plus/docs/status_screen/)

  

- Let this fuzzing campaign run for at least 60 minutes, then end it with ctrl+c

  

- You will have generated a corpus of inputs that can be used to skip the slow beginning part of future campaigns, so let’s do that by running: `cp OUT/default/queue/* seeds/`

  

- Additionally, any crashing inputs found during your fuzzing campaign can be found in the directory `OUT/default/crashes`

  

- Copy the whole `OUT` directory to somewhere safe, as we will now try running with different error detecting sanitizers (for example `cp -r OUT /app/OUT_NO_SANITIZERS`)

  




- You will need to rebuild the target programs with `AFL_USE_ASAN=1 /app/build/build_program.sh`

  

- Notice that we are setting the environment variable `AFL_USE_ASAN` to `1`

  

- Having rebuilt the program with AddressSanitizer enabled, you will need to fuzz your target program again with the same command (`afl-fuzz -i seeds -o OUT -- ./YOUR_TARGET_PROGRAM-sanitize-fuzzer`). If you copied your queue into `seeds`, you will find that exploration will be much faster this time; and you can run the fuzzer for less time.

  

- Again, copy the `OUT` directory to somewhere safe, e.g. `cp -r OUT OUT_ASAN`

  

- Repeat for LeakSanitizer (`AFL_USE_LSAN=1`), MemorySanitizer (`AFL_USE_MSAN=1`), UndefinedBehaviourSanitizer (`AFL_USE_UBSAN=1`)