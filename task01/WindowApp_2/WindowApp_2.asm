format          PE GUI 4.0                                                      ; ������ PE. ������ GUI 4.0.
entry           start                                                           ; ����� �����
include         'win32a.inc'                                                    ; ������ ����������� ��������� ����������.
 
_style           equ             WS_VISIBLE+WS_DLGFRAME+WS_SYSMENU              ; ����� ����. ����������� ������ ���������� �� ��������� ����
 
;=== ������� ���� ============================================================
 
section         '.text' code readable executable
 
  start: 
                invoke          GetModuleHandle,0                               ; ������� ���������� ����������.
                mov             [wc.hInstance],eax                              ; �������� ���������� ���������� � ���� ��������� ���� (wc)
                invoke          LoadIcon,0,IDI_ASTERISK                         ; ��������� ����������� ������ IDI_ASTERISK
                mov             [wc.hIcon],eax                                  ; �������� ���������� ������ � ���� ��������� ���� (wc)
                invoke          LoadCursor,0,IDC_ARROW                          ; ��������� ����������� ������ IDC_ARROW
                mov             [wc.hCursor],eax                                ; �������� ���������� ������� � ���� ��������� ���� (wc)
                mov             [wc.lpfnWndProc],WindowProc                     ; ������� ��������� �� ���� ��������� ��������� ����
                mov             [wc.lpszClassName],_class                       ; ������� ��� ������ ����
                mov             [wc.hbrBackground],COLOR_WINDOW+1               ; ������� ���� �����
                invoke          RegisterClass,wc                                ; �������������� ��� ����� ����
                test            eax,eax                                         ; �������� �� ������ (eax=0).
                jz              error                                           ; ���� 0, �� ������ - ������� �� error.
                
                invoke          CreateWindowEx,0,_class,_title,_style,128,128,256,192,NULL,NULL,[wc.hInstance],NULL  ; �������� ��������� ���� �� ������ ������������������� ������. � eax ���������� ���������� ����.
                test            eax,eax                                         ; �������� �� ������ (eax=0).
                jz              error                                           ; ���� 0, �� ������ - ������� �� error.
                
                mov             [wHMain],eax                                    ; �������� ���������� ���������� ����
 
;--- ���� ��������� ��������� ------------------------------------------------
 
  msg_loop:
                invoke          GetMessage,msg,NULL,0,0                         ; �������� ��������� �� ������� ��������� ����������
                or              eax,eax                                         ; ���������� eax � 0
                jz              end_loop                                        ; ���� 0 �� ������ ��������� WM_QUIT - ������� �� ����� �������� ���������, ���� �� 0 - ���������� ������������ �������
  msg_loop_2:
                invoke          TranslateMessage,msg                            ; �������������� ������� ��������� ���������. ������������ ��������� ���������� ���������� �� ������� � �������.
                invoke          DispatchMessage,msg                             ; ���������� ��������� ��������������� ���������� ��������� ��������� (WindowProc ...).
                jmp             short msg_loop                                  ; �������������
  error:
                invoke          MessageBox,NULL,_error,NULL,MB_ICONERROR+MB_OK  ; ������� ���� � �������
  end_loop:
                invoke          ExitProcess,[msg.wParam]                        ; ����� �� ���������.
 
;--- ��������� ��������� ��������� ���� (������� ����, ������� ���������, ������� �������)
 
proc            WindowProc      hWnd,wMsg,wParam,lParam
                push            ebx esi edi                                     ; �������� ��� ��������
                cmp             [wMsg],WM_DESTROY                               ; �������� �� WM_DESTROY
                je              .wmdestroy                                      ; �� ���������� wmdestroy
                cmp             [wMsg],WM_CREATE                                ; �������� �� WM_CREATE
                je              .wmcreate                                       ; �� ���������� wmcreate
  .defwndproc:
                invoke          DefWindowProc,[hWnd],[wMsg],[wParam],[lParam]   ; ������� �� ���������. ������������ ��� ���������, ������� ������������ ��� ����.
                jmp             .finish 
  .wmcreate:
                xor             eax,eax
                jmp             .finish
  .wmdestroy:                                                                   ; ���������� ��������� WM_DESTROY. ����������.
                invoke          PostQuitMessage,0                               ; �������� ��������� WM_QUIT � ������� ���������, ��� ��������� GetMessage ������� 0. ���������� ��� ������ �� ���������. ���������� ������ �������� �����.
                xor             eax,eax                                         ; ���� ���� ��������� ���� ������������ �����-���� ���������, �� ��� ������ ������� � eax 0. ����� ��������� ������� ���� ��������������.
  .finish:
                pop             edi esi ebx                                     ; ����������� ��� ��������
                ret
endp
 
;=== ������� ������ ==========================================================
 
section         '.data' data readable writeable
 
_class          db              'FASMWIN32',0                                   ; �������� ������������ ������.
_title          db              'Win32 program template',0                      ; ����� � ��������� ����.
_error          db              'Startup failed.',0                             ; ����� ������
 
wHMain          dd              ?                                               ; ���������� ����
 
wc              WNDCLASS                                                        ; ��������� ����. ��� ������� RegisterClass
msg             MSG                                                             ; ��������� ���������� ���������, ������� ������� �������� ����� ���������.
 
;=== ������� ������� =========================================================
section         '.idata' import data readable writeable
 
library         kernel32,'KERNEL32.DLL',user32,'USER32.DLL'
 
import          kernel32,\
                GetModuleHandle,'GetModuleHandleA',\
                ExitProcess,'ExitProcess'
 
import          user32,\
                LoadIcon,'LoadIconA',\
                LoadCursor,'LoadCursorA',\
                RegisterClass,'RegisterClassA',\
                CreateWindowEx,'CreateWindowExA',\
                GetMessage,'GetMessageA',\
                TranslateMessage,'TranslateMessage',\
                DispatchMessage,'DispatchMessageA',\
                MessageBox,'MessageBoxA',\
                DefWindowProc,'DefWindowProcA',\
                PostQuitMessage,'PostQuitMessage'