LPARAMETERS tnx as Integer, tny as Integer
	IF VARTYPE(m.tnx) = 'N' AND VARTYPE(m.tny) = 'N'
		MOUSE AT m.tny, m.tnx PIXELS
		INKEY(.05)
	ENDIF

	DEFINE POPUP shortcut SHORTCUT RELATIVE FROM MROW(), MCOL()

	DEFINE BAR _med_undo OF shortcut PROMPT "��������" ;
		KEY CTRL+R, "Ctrl+R" ;
		PICTURE "..\bmp\16x16\undo.bmp" ;
		MESSAGE "�������� ��������� ��������"

	DEFINE BAR _med_redo OF shortcut PROMPT "���������" ;
		KEY CTRL+Z, "Ctrl+Z" ;
		PICTURE "..\bmp\16x16\redo.bmp" ;
		MESSAGE "��������� ��������� ��������"

	DEFINE BAR 3 OF shortcut PROMPT "\-"

	DEFINE BAR _med_cut OF shortcut PROMPT "��������" ;
		KEY CTRL+X, "Ctrl+X" ;
		PICTURE "..\bmp\16x16\cut.bmp" ;
		MESSAGE "��������� � ����� ������ � �������"

	DEFINE BAR _med_copy OF shortcut PROMPT "����������" ;
		KEY CTRL+C, "Ctrl+C" ;
		PICTURE "..\bmp\16x16\copy.bmp" ;
		MESSAGE "��������� � ����� ������"

	DEFINE BAR _med_paste OF shortcut PROMPT "��������" ;
		KEY CTRL+V, "Ctrl+V" ;
		PICTURE "..\bmp\16x16\paste.bmp" ;
		MESSAGE "�������� �� ������ ������"

	DEFINE BAR 7 OF shortcut PROMPT "\-"

	DEFINE BAR _med_clear OF shortcut PROMPT "��������" ;
		PICTRES _med_clear ;
		MESSAGE "�������� ���������� � �� �������� ��� � ����� ������"

	DEFINE BAR _med_slcta OF shortcut PROMPT "�������� ��" ;
		KEY CTRL+A, "Ctrl+A" ;
		PICTRES _med_slcta ;
		MESSAGE "�������� ���� �����"

	ACTIVATE POPUP shortcut