import os
#import base64
#from Crypto.Cipher import AES

settings = {'homedir' : None}

# def get_key():
#     return os.environ['ITBI_KEY'].encode()


def load_config(config_file=None):  
    from pyhocon import ConfigFactory
    global settings
    homedir = settings['homedir']
    if config_file is None:
        config_file = homedir + "/config/settings.conf"
    settings = ConfigFactory.parse_file(config_file)
    settings['homedir'] = homedir


def get_setting(key):
    keys = key.split('.')
    s = settings.get(keys[0], default = None)
    if s is None:
        return None
    for p in keys[1:]:
        s = s[p]
    return decrypt(s)


def set_setting(key, value):
    keys = key.split('.')
    s = settings
    k = keys[0]
    v = s[k]
    for p in keys[1:]:
        k = p
        s = v
        v = s[k]
    s[k] = value


def encrypt_setting(key):
    s = get_setting(key)
    c = encrypt(s)
    set_setting(key, c)


def encrypt(data):
    return data
    # if data.startswith("aes256#"):
    #     return data
    # data = data.encode()
    # key = get_key()
    # cipher = AES.new(key, AES.MODE_EAX)
    # ciphertext, tag = cipher.encrypt_and_digest(data)
    # return "aes256#" + base64.b64encode(cipher.nonce + tag + ciphertext).decode()


def decrypt(data):
    return data
    # if not isinstance(data, str) or not data.startswith("aes256#"):
    #     return data
    # key = get_key()
    # b = base64.b64decode(data[7:].encode())
    # nonce = b[0:16]
    # tag = b[16:32]
    # ciphertext = b[32:]
    
    # cipher = AES.new(key, AES.MODE_EAX, nonce)
    # return cipher.decrypt_and_verify(ciphertext, tag)


def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""
    from datetime import date, datetime
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    raise TypeError ("Type %s not serializable" % type(obj))
