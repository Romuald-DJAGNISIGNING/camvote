@echo off
cd /d c:\Users\bkbad\OneDrive\Desktop\romuald\camvote
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080 > run-web.out.log 2> run-web.err.log
