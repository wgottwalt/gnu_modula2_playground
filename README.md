This is my playground for the GNU Modula-2 GCC frontend introduced in GCC 13.

This code is written against GCC 14 snapshot 20240421 and up. There are several
reasons for this.
1. The Modula-2 frontend in GCC 13 still has some odd issues which I
   encountered during playing around with this. They are basically all fixed in
   the GCC 14 snapshots.
2. Most distribution, which provide a build of the gm2 compiler messed up
   packaging. Here I mean the Modula-2 runtime, which is a pain in the ass if
   not also provided as static libs. Seriously, you really want to compile this
   into your Modula-2 binaries. Which is done via the -static-libgm2 parameter
   in the makefiles. Without that your binaries will require the Modula-2 libs
   provided only by the gcc-gm2 package in most of the distributions.
   Statically linking the runtime reduces the lib requirements down to the clib,
   cxxlib, gcclib and the libs you add on your own.
3. In GCC 13 the gm2 frontend behaves a bit odd which makes using globing
   mechanisms in makefiles quite annoying.

If you are on Arch Linux you could use my GCC 15 snapshot packages to get the
latest Modula-2 support. (https://aur.archlinux.org/packages/gcc-snapshot)

All the Modula-2 code in here should be proper ISO standard Modula-2 code
combined with some PIMx calls if no matching ISO call is available. Though I
will really try to stick to the ISO standard. I used to code quite a lot of
Pascal in the old days so I will stick with a coding style more comparable to
Free Pascal instead of the now odd looking Modula-2 styles used back in the
days.

There will be also some odd stuff here, because I really enjoy coding Modula-2.
I will try to complete everything I try out, but some of the stuff will be work
in progress.

-- image viewer --

This is a simple image viewer using the SDL2 and SDL2_image libs to display all
kinds of images. I included a nice example JPEG which gets loaded if the viewer
is started without an argument. In this example I enable support of all image
formats tha are supported by SLD2_image, but that will fail if you miss some
of the more niche formats like AVIF. In that case just change the parameter of
IMG_INIT(). The image will be displayed for about 3 seconds, then the viewer
closes. If you look into the SDL2 wrapper you can see that I actually added
all the SDL2 event stuff to be able to wait for a quit or keyboard event. But
this did not work for me. Here the Modula-2 runtime runs into some really odd
issues I can not figure out. It is odd, because the Raylib uses a similar
technique and there it works just fine.

-- nice to know --

Various examples and tricks I found myself by reading the GCC Modula-2 backend
code and just playing around. Some of this is not mentioned in the most
Modula-2 books.

-- coroutines --

That is an example on how to use PIM coroutines. I had some trouble with the
ISO version. I put the PIM version here, because they seem to work nicely. It
is just a small example to get a feeling for this, after all that coroutine
mechanism is quite different from C++ coroutines. At the beginning it was quite
hard to get it to work, because of a simple reason. The stack sizes old manuals
are talking about are often far to small. You need at least a 16 KiB stack for
every coroutine or you run in very hard to understand runtime errors.

-- raylib --

Just some example code about how to use the really nice GNU Modula-2 clib
interfacing mechanics to play around with the famous raylib. For now the Raylib
is incomplete and in the most cases will only provide what is needed to get the
examples running. But I plan to complete this, because I really enjoy how well
that works. (Just to mention it: I also work on Xlib, libpci and SDL2 wrapper
code, but they are far more complex.)
