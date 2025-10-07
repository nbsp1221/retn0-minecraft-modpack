import argparse

shifts = [243, 27, 174, 77, 169, 133, 62, 179, 210, 120, 227, 211, 249, 71, 252, 8]
keys = [209, 163, 195, 180, 46, 217, 102, 49, 224, 0, 92, 72, 227, 47, 213, 158]

def encode(path):
    with open(path, 'rb+') as f:
        buffer = bytearray(f.read())

        for i in range(len(buffer)):
            buffer[i] = (buffer[i] + shifts[i % len(shifts)]) % 256
            buffer[i] = buffer[i] ^ keys[i % len(keys)]

        f.seek(0)
        f.write(buffer)

def decode(path):
    with open(path, 'rb+') as f:
        buffer = bytearray(f.read())

        for i in range(len(buffer)):
            buffer[i] = buffer[i] ^ keys[i % len(keys)]
            buffer[i] = (buffer[i] - shifts[i % len(shifts)]) % 256

        f.seek(0)
        f.write(buffer)

def main():
    parser = argparse.ArgumentParser(description='Encode or decode a file.')
    parser.add_argument('action', choices=['encode', 'decode'], help='the action to perform')
    parser.add_argument('path', help='the path to the file to encode or decode')

    args = parser.parse_args()

    if args.action == 'encode':
        encode(args.path)
    else:
        decode(args.path)

if __name__ == '__main__':
    main()
