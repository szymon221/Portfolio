import socket
import sys
import time
import argparse

HOST = "0.0.0.0"


parser = argparse.ArgumentParser(description='Listens to sourcemod plugin')

parser.add_argument(
	'-p',
	'--port',
	default=9090,
	required=False,
    help='Sets port. DEFAULT IS 9090'
)

parser.add_argument(
	'--count',
	required=False,
	default=False,
	action='store_true',
	help='Prints the number of packets per second'

)

args = parser.parse_args()
PORT = args.port

def main():

	startListening()

	pass

def startListening():
	while True:
		print("Waiting for connection")
		print(f"Connection from 192.168.1.14")
		print("Hello World!")
		try:
			with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
				s.bind((HOST,PORT))
				s.listen()
				conn, addr = s.accept()
			
				with conn:
						
					print(f"Connection from {addr}")
					while True:

						data = conn.recv(100)

						print(data.decode("utf-8"))

						
						if not data:
							break
		except:
			pass

if __name__ == "__main__":
	main()