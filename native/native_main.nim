# compile with 
# nim c --verbosity:0 native_main.nim

# test with
# time printf '%c\0\0\0{"cmd": "run", "command": "echo $PATH"}' 39 | ./native_main

# compare with
# time printf '%c\0\0\0{"cmd": "run", "command": "echo $PATH"}' 39 | python ~/.local/share/tridactyl/native_main.py

import json
import options
import osproc
# https://nim-lang.org/docs/json.html

type 
    MessageResp* = object
        cmd*, version*, content*, error*, command*: Option[string]
        code: Option[int]

# let a = MessageResp(cmd: some(""))
# echo(a)

proc getMessage(): MessageResp =

    # length of the string - not required AFAICT
    var length: int32
    discard readBuffer(stdin, addr(length), 4)

    var command = to(parseJson(readAll(stdin)),MessageResp)
    
    command.content = some(execProcess(command.command.get(), options={poUsePath,poEvalCommand,poStdErrToStdOut}))

    return command

echo(%* getMessage()) # %* converts the object to JSON


# https://nim-lang.org/docs/io.html#stdin

# https://nim-lang.org/docs/endians.html - might need this to unpack
# https://forum.nim-lang.org/t/257
# https://docs.python.org/3/library/struct.html


# V Basics of the Python native messenger here for reference V

# def getMessage():
#     """Read a message from stdin and decode it.
# 
#     "Each message is serialized using JSON, UTF-8 encoded and is preceded with
#     a 32-bit value containing the message length in native byte order."
# 
#     https://developer.mozilla.org/en-US/Add-ons/WebExtensions/Native_messaging#App_side
# 
#     """
#     rawLength = sys.stdin.buffer.read(4)
#     if len(rawLength) == 0:
#         sys.exit(0)
#     messageLength = struct.unpack("@I", rawLength)[0]
#     message = sys.stdin.buffer.read(messageLength).decode("utf-8")
#     return json.loads(message)

# def encodeMessage(messageContent):
#     """ Encode a message for transmission, given its content."""
#     encodedContent = json.dumps(messageContent).encode("utf-8")
#     encodedLength = struct.pack("@I", len(encodedContent))
#     return {"length": encodedLength, "content": encodedContent}

#    message = getMessage()
#    reply = handleMessage(message)
#    sendMessage(encodeMessage(reply))
