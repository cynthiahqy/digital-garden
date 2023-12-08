## QR Code
library(qrcode)
qrcode_gen <- qrcode::qr_code("https://www.cynthiahqy.com/research")
plot(qrcode_gen)
generate_svg(qrcode_gen, file = "qrcode-research.svg")
