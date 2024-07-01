// version with leading zero
// for 0xf - will be 0x0f and so on
function toHexString(bigintVal) {
    
    var hex = bigintVal.toString(16);
    if (hex.length %2 != 0) {
        hex = '0' + hex;
    }
    return hex;
}
module.exports = {
    toHexString
}