@echo off
cd bin
if not exist hgme.hdll copy ..\..\hl\Release\hgme.hdll hgme.hdll
hl nsf2wav.hl ../mario.nsf
pause
