format PE GUI

entry start

include 'win32a.inc'
include 'opengl.inc'

section '.text' code executable

start:

        invoke  GetModuleHandle,0
        mov     [wc.hInstance],eax
        invoke  LoadIcon,0,IDI_APPLICATION
        mov     [wc.hIcon],eax
        invoke  LoadCursor,0,IDC_ARROW
        mov     [wc.hCursor],eax
        invoke  RegisterClass,wc
        invoke  CreateWindowEx,WS_EX_LAYERED+WS_EX_TOPMOST,name,name,WS_POPUP,CW_USEDEFAULT,CW_USEDEFAULT,432,432,NULL,NULL,[wc.hInstance],NULL
        mov     [hwnd],eax
        invoke  SetLayeredWindowAttributes,[hwnd],0,128,LWA_COLORKEY+LWA_ALPHA

  msg_loop:
        invoke  GetMessage,msg,NULL,0,0
        or      eax,eax
        jz      end_loop
        invoke  TranslateMessage,msg
        invoke  DispatchMessage,msg
        jmp     msg_loop

  end_loop:
        invoke  ExitProcess,[msg.wParam]

proc WindowProc hwnd,wmsg,wparam,lparam
        push    ebx esi edi
        cmp     [wmsg],WM_CREATE
        je      .wmcreate
        cmp     [wmsg],WM_PAINT
        je      .wmpaint
        cmp     [wmsg],WM_KEYDOWN
        je      .wmkeydown
        cmp     [wmsg],WM_DESTROY
        je      .wmdestroy
  .defwndproc:
        invoke  DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
        jmp     .finish
  .wmcreate:
        invoke  GetDC,[hwnd]
        mov     [hdc],eax
        mov     edi,pfd
        mov     ecx,sizeof.PIXELFORMATDESCRIPTOR shr 2
        xor     eax,eax
        rep     stosd
        mov     [pfd.nSize],sizeof.PIXELFORMATDESCRIPTOR
        mov     [pfd.nVersion],1
        mov     [pfd.dwFlags],PFD_SUPPORT_OPENGL+PFD_DOUBLEBUFFER+PFD_DRAW_TO_WINDOW
        mov     [pfd.iLayerType],PFD_MAIN_PLANE
        mov     [pfd.iPixelType],PFD_TYPE_RGBA
        mov     [pfd.cColorBits],32
        mov     [pfd.cDepthBits],16
        mov     [pfd.cAccumBits],0
        mov     [pfd.cStencilBits],0
        invoke  ChoosePixelFormat,[hdc],pfd
        invoke  SetPixelFormat,[hdc],eax,pfd
        invoke  wglCreateLayerContext,[hdc],0
        mov     [hrc],eax
        invoke  wglMakeCurrent,[hdc],[hrc]
        invoke  GetClientRect,[hwnd],rc
        invoke  glViewport,0,0,[rc.right],[rc.bottom]
        invoke  glEnable,GL_DEPTH_TEST
        invoke  GetTickCount
        mov     [clock],eax
        invoke  ShowWindow,[hwnd],SW_SHOW
        xor     eax,eax
        jmp     .finish
  .wmpaint:
        invoke  GetTickCount
        sub     eax,[clock]
        cmp     eax,10
        jb      .animation_ok
        add     [clock],eax
        invoke  glRotatef,[xRotation],1.0,0.0,0.0
        invoke  glRotatef,[yRotation],0.0,1.0,0.0
        invoke  glRotatef,[zRotation],0.0,0.0,1.0
      .animation_ok:
        invoke  glClear,GL_COLOR_BUFFER_BIT+GL_DEPTH_BUFFER_BIT
        invoke  glBegin,GL_QUADS
        invoke  glColor3f,1.0,0.1,0.1
        invoke  glVertex3f,-0.5,-0.5,0.5
        invoke  glColor3f,0.1,0.1,0.1
        invoke  glVertex3f,0.5,-0.5,0.5
        invoke  glColor3f,0.1,0.1,1.0
        invoke  glVertex3f,0.5,0.5,0.5
        invoke  glColor3f,1.0,0.1,1.0
        invoke  glVertex3f,-0.5,0.5,0.5

        invoke  glColor3f,0.9,0.5,0.1
        invoke  glVertex3f,0.5,-0.5,0.5
        invoke  glColor3f,0.1,0.2,0.7
        invoke  glVertex3f,0.5,-0.5,-0.5
        invoke  glColor3f,0.4,0.2,1.0
        invoke  glVertex3f,0.5,0.5,-0.5
        invoke  glColor3f,1.0,0.3,0.25
        invoke  glVertex3f,0.5,0.5,0.5

        invoke  glColor3f,0.3,0.74,0.24
        invoke  glVertex3f,0.5,-0.5,-0.5
        invoke  glColor3f,0.2,0.9,0.1
        invoke  glVertex3f,-0.5,-0.5,-0.5
        invoke  glColor3f,0.41,0.63,0.14
        invoke  glVertex3f,-0.5,0.5,-0.5
        invoke  glColor3f,0.55,0.3,1.0
        invoke  glVertex3f,0.5,0.5,-0.5

        invoke  glColor3f,0.9,0.8,0.5
        invoke  glVertex3f,-0.5,-0.5,-0.5
        invoke  glColor3f,0.2,0.3,0.67
        invoke  glVertex3f,-0.5,-0.5,0.5
        invoke  glColor3f,0.08,0.1,0.65
        invoke  glVertex3f,-0.5,0.5,0.5
        invoke  glColor3f,0.9,0.7,0.48
        invoke  glVertex3f,-0.5,0.5,-0.5

        invoke  glColor3f,1.0,0.44,0.0
        invoke  glVertex3f,-0.5,-0.5,-0.5
        invoke  glColor3f,0.76,0.15,0.1
        invoke  glVertex3f,0.5,-0.5,-0.5
        invoke  glColor3f,0.24,0.46,0.2
        invoke  glVertex3f,0.5,-0.5,0.5
        invoke  glColor3f,0.9,0.45,1.0
        invoke  glVertex3f,-0.5,-0.5,0.5

        invoke  glColor3f,0.1,0.25,0.35
        invoke  glVertex3f,-0.5,0.5,0.5
        invoke  glColor3f,0.9,0.1,0.9
        invoke  glVertex3f,0.5,0.5,0.5
        invoke  glColor3f,0.3,0.6,1.0
        invoke  glVertex3f,0.5,0.5,-0.5
        invoke  glColor3f,0.1,0.5,1.0
        invoke  glVertex3f,-0.5,0.5,-0.5

        invoke  glEnd
        invoke  SwapBuffers,[hdc]
        xor     eax,eax
        jmp     .finish
  .wmkeydown:
        cmp     [wparam],0x57
        je      .key_w
        cmp     [wparam],0x53
        je      .key_s
        cmp     [wparam],0x41
        je      .key_a
        cmp     [wparam],0x44
        je      .key_d
        cmp     [wparam],0x51
        je      .key_q
        cmp     [wparam],0x45
        je      .key_e
        cmp     [wparam],VK_SPACE
        je      .key_space
        cmp     [wparam],VK_ESCAPE
        je      .key_escape
      .key_w:
        fld     dword [xRotation]
        fadd    dword [rotAcc]
        fstp    dword [xRotation]
        xor     eax,eax
        jmp     .finish
      .key_s:
        fld     dword [xRotation]
        fsub    dword [rotAcc]
        fstp    dword [xRotation]
        xor     eax,eax
        jmp     .finish
      .key_a:
        fld     dword [yRotation]
        fadd    dword [rotAcc]
        fstp    dword [yRotation]
        xor     eax,eax
        jmp     .finish
      .key_d:
        fld     dword [yRotation]
        fsub    dword [rotAcc]
        fstp    dword [yRotation]
        xor     eax,eax
        jmp     .finish
      .key_q:
        fld     dword [zRotation]
        fadd    dword [rotAcc]
        fstp    dword [zRotation]
        xor     eax,eax
        jmp     .finish
      .key_e:
        fld     dword [zRotation]
        fsub    dword [rotAcc]
        fstp    dword [zRotation]
        xor     eax,eax
        jmp     .finish
      .key_space:
        fldz
        fst    dword [xRotation]
        fst    dword [yRotation]
        fstp   dword [zRotation]
        xor     eax,eax
        jmp     .finish
      .key_escape:
  .wmdestroy:
        invoke  wglMakeCurrent,0,0
        invoke  wglDeleteContext,[hrc]
        invoke  ReleaseDC,[hwnd],[hdc]
        invoke  PostQuitMessage,0
        xor     eax,eax
  .finish:
        pop     edi esi ebx
        ret
endp

section '.data' data readable writable
        name    db   'AweSM',0

        xRotation GLfloat 0.0
        yRotation GLfloat 0.2
        zRotation GLfloat 0.0
        rotAcc GLfloat 0.1

        wc WNDCLASS 0,WindowProc,0,0,NULL,NULL,NULL,NULL,NULL,name
        hwnd dd ?
        hdc dd ?
        hrc dd ?

        msg MSG
        rc RECT
        pfd PIXELFORMATDESCRIPTOR

        clock dd ?

section '.idata' data readable import
        library kernel,'kernel32',user,'user32',opengl,'opengl32',gdi,'gdi32'
        import kernel,ExitProcess,'ExitProcess',GetModuleHandle,'GetModuleHandleA',GetTickCount,'GetTickCount'
        import user,RegisterClass,'RegisterClassA',CreateWindowEx,'CreateWindowExA',ShowWindow,'ShowWindow',GetMessage,'GetMessageA',\
               DefWindowProc,'DefWindowProcA',DispatchMessage,'DispatchMessageA',PostQuitMessage,'PostQuitMessage',LoadIcon,'LoadIconA',\
               LoadCursor,'LoadCursorA',TranslateMessage,'TranslateMessage',GetDC,'GetDC',GetClientRect,'GetClientRect',ReleaseDC,'ReleaseDC',\
               SetLayeredWindowAttributes,'SetLayeredWindowAttributes'
        import gdi,ChoosePixelFormat,'ChoosePixelFormat',SetPixelFormat,'SetPixelFormat',SwapBuffers,'SwapBuffers'
        import opengl,wglCreateLayerContext,'wglCreateLayerContext',wglMakeCurrent,'wglMakeCurrent',glViewport,'glViewport',glRotatef,'glRotatef',\
               glClear,'glClear',glBegin,'glBegin',glColor3f,'glColor3f',glVertex3f,'glVertex3f',glEnd,'glEnd',wglDeleteContext,'wglDeleteContext',\
               glEnable,'glEnable'