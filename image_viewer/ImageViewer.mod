(*!m2iso*)
MODULE ImageViewer;

FROM SYSTEM IMPORT ADR, BITSET32, CARDINAL32, CAST, INTEGER32;
IMPORT ProgramArgs;
IMPORT TextIO;
IMPORT MiniSDL2;
IMPORT MiniSDL2image;

PROCEDURE BSet32Int32(Val: BITSET32): INTEGER32;
BEGIN
  RETURN CAST(INTEGER32, Val);
END BSet32Int32;

PROCEDURE BSet32UInt32(Val: BITSET32): CARDINAL32;
BEGIN
  RETURN CAST(CARDINAL32, Val);
END BSet32UInt32;

PROCEDURE GetImageFilename(VAR Filename: ARRAY OF CHAR): BOOLEAN;
BEGIN
  ProgramArgs.NextArg;
  IF ProgramArgs.IsArgPresent() THEN
    TextIO.ReadToken(ProgramArgs.ArgChan(), Filename);

    RETURN TRUE;
  END;

  RETURN FALSE;
END GetImageFilename;

CONST
  TEST_IMAGE = "bee.jpeg";

VAR
  Window: MiniSDL2.PSDL_Window;
  WindowSurface, ImageSurface: MiniSDL2.PSDL_Surface;
  Filename: ARRAY[0..255] OF CHAR;

BEGIN
  IF MiniSDL2.SDL_Init(BSet32Int32(MiniSDL2.SDL_INIT_VIDEO)) = 0 THEN
    IF MiniSDL2image.IMG_Init(BSet32Int32(MiniSDL2image.IMG_INIT_ALL_FORMATS)) = 0 THEN
      IF GetImageFilename(Filename) THEN
        ImageSurface := MiniSDL2image.IMG_Load(Filename);
      ELSE
        ImageSurface := MiniSDL2image.IMG_Load(TEST_IMAGE);
      END;
      IF ImageSurface <> NIL THEN
        Window := MiniSDL2.SDL_CreateWindow("SDL2 Image Window", 0, 0, ImageSurface^.W,
                                            ImageSurface^.H, 0);
        IF Window <> NIL THEN
          WindowSurface := MiniSDL2.SDL_GetWindowSurface(Window);
          IF WindowSurface <> NIL THEN
            MiniSDL2.SDL_UpperBlit(ImageSurface, NIL, WindowSurface, NIL);
            MiniSDL2.SDL_UpdateWindowSurface(Window);
            MiniSDL2.SDL_Delay(3000);
          END;
          MiniSDL2.SDL_DestroyWindow(Window);
        END;

        MiniSDL2.SDL_FreeSurface(ImageSurface);
      ELSE
        MiniSDL2.SDL_Log("ImageSurface is NIL: %s\n", MiniSDL2.SDL_GetError());
      END;

      MiniSDL2image.IMG_Quit;
    ELSE
      MiniSDL2.SDL_Log("IMG_Init failed: %s\n", MiniSDL2.SDL_GetError());
    END;

    MiniSDL2.SDL_Quit;
  END;
END ImageViewer.
