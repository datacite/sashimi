# Test-only RSA keypair for JWT encode/decode in specs.
# Generated once per RSpec process. Not used in any deployed environment.
require "openssl"

key = OpenSSL::PKey::RSA.generate(2048)
ENV["JWT_PRIVATE_KEY"] = key.to_pem
ENV["JWT_PUBLIC_KEY"] = key.public_key.to_pem
