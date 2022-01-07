const fizzbuzz = require("../fizzbuzz");

payload = {
    body: {"number": 3}
};

expect.extend({
    async getFizzBuzz(data) {
        const result = await fizzbuzz.handler(payload);
    }
});

test('Test fizz', () => {
    expect(fizzbuzz.handler(payload)).toBe({message: "fizz"});
});