require('pca9685')

pca = pca9685.create(0, 0x40)
pca:init(1, 2)

pca:setMode1(0x01)
pca:setMode2(0x04)

pca:setOnOf(0, 200, 600)