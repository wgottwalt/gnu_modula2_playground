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
4. Avoid small size optimizations (-Os). These result in very odd errors,
   especially if combined with wrappers around libs (libc.def).
5. Do not use SHORTREAL (aka float) with the c-runtime wrapped printf function
   and the %f placeholder. In C %f is meant for doubles but also works with
   floats. This is not true for Modula-2. Here every variable assigned to the %f
   placeholder is always interpreted as double, producing really odd output.
   Avoid SHORTREAL with c-runtime wrapped libs in general. There also seems to
   be no benefit in SHORTREALs at all in the case of packing or vectorization
   (SIMD).
6. If you can use the c-runtime (libc.def), do so and avoid Modula-2 lib
   functions. They are slow, really really horrible slow.

If you are on Arch Linux you could use my GCC 15 snapshot packages to get the
latest Modula-2 support. (https://aur.archlinux.org/packages/gcc-snapshot)

I am also a developer contributing to GCC and are able to bring code upstream.
If you encounter odd issues in the Modula-2 frontend, you can contact me here
and I will try to fix it in upstream.

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
formats that are supported by SLD2_image. But this will fail if you are missing
some of the libs of the niche formats like AVIF. In that case just change the
parameter of the IMG_Init() procedure. The viewer will react to a window managers
"application close event" or the escape key to end the viewer.

-- nice to know --

Various examples and tricks I found myself by reading the GCC Modula-2 backend
code and just playing around. Some of this is not mentioned in the most Modula-2
books.

-- coroutines --

That is an example on how to use PIM coroutines. I had some trouble with the
ISO version. I put the PIM version here, because they seem to work nicely. It
is just a small example to get a feeling for this, after all that coroutine
mechanism is quite different from C++ coroutines. At the beginning it was quite
hard to get it to work, because of a simple reason. The stack sizes old manuals
are talking about are often far to small. You need at least a 16 KiB stack for
every coroutine or you run into very hard to understand runtime errors.

-- raylib --

Just some example code about how to use the really nice GNU Modula-2 clib
interfacing mechanics to play around with the famous raylib. For now the Raylib
is incomplete and in the most cases will only provide what is needed to get the
examples running. But I plan to complete this, because I really enjoy how well
that works. (Just to mention it: I also work on Xlib, libpci and SDL2 wrapper
code, but they are far more complex.) I will provide a complete Raylib wrapper,
it is just a matter of time. Some parts won't be a wrapper but native Modula-2
implementations, because some parts of Raylib are just macros and these are not
possible in Modula-2. And there are all the basic vector math stuff where it
does not make much sense to "wrap". Doing that natively in Modula-2 may also
yield a slightly better performance.

-- libpciaccess --

This is an attempt to properly wrap a C based library and is complete, nothing
is missing. There I split between bindings and the actual Modula-2 interface.
The reason for this is simple, the C based lib has functions returning char
arrays, something which is difficult to deal with in Modula-2. Modula-2 has a
much stricter type system. Things like returning dynamic allocated strings is a
typical C thing and is handled differently in Modula-2. There are dynamic
strings types in the Modula-2 libs, but they are not the same. Plus, you always
have to figure out how ownership of these allocated memory is done. Is the lib
freeing the memory or does the user of the lib has to deal with it? For that
reason this wrapper copies the string to a fixed length string, a defined type
which can be used as a return type in Modula-2 procedures. Another really
difficult part are C bitfields which are an extreme example of packed types. I
had to do thourough testing and GCC code reading to understand how to deal with
that, hence I included some testing code. The way how it is done here is a GCC
feature. I'm pretty sure that this will not work with other Modula-2 compilers.
