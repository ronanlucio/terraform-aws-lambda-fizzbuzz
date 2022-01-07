/** 
 * Function that handles fizzbuzz logic
 * @author  Ronan Lucio Pereira
 * @param   {object}
 *              number: integer to be checked against fizzbuzz algorithm
 * @returns {object}
 *              statusCode: HTTP code to send in response
 *              message: Message to be sent in response
 */
 exports.handler = async (event) => {
    
    console.log("Event:", event);
    
    let statusCode = 200;
    let message = "";
    let inputValidation = validateInput(event);
    
    //console.log(inputValidation);

    if (inputValidation.valid) {
        var number = JSON.parse(event.body).number
        statusCode = 200;
        
        if ((number % 3) == 0 && (number % 5) == 0 ) {
            message = "fizzbuzz";
        } else if (number % 3 == 0) {
            message = "fizz";
        } else if (number % 5 == 0) {
            message = "buzz";
        } else {
            message = "";
        }
    } else {
        statusCode = inputValidation["statusCode"];
        message = inputValidation["message"];
    }
    
    return getResponse(statusCode, message);
};

/** 
 * Function to validade the input for fizzbuzz.handle function
 * @author  Ronan Lucio Pereira
 * @param   {object}
 *              event: JSON object passed to Lambda function
 * @returns {object}
 *              valid: true if event contains a 'number' key with a valid value
 *              statusCode: HTTP code to send in response
 *              message: Message to be sent in response
 */
 function validateInput(event) {

    let valid = true;
    let statusCode = 200;
    let message = "";

    if (event.body) {
        var body = JSON.parse(event.body);

        if (body.number && Number.parseInt(body.number)) {
            // if number contains a valid number
            valid = true;
            statusCode = 200;
            message = "";
        } else {
            // if number doesn't contain a valid number
            valid = false;
            statusCode = 400;
            message = "You must inform the number to be checked";    
        }

    } else {
        // if number parameter is NOT informed
        valid = false;
        statusCode = 400;
        message = "You must inform the number to be checked";
    }

    return {
        valid: valid,
        statusCode: statusCode,
        message: message
    }
}

/** 
 * Function to assemble the response object
 * @author  Ronan Lucio Pereira
 * @param   {object}
 *              statusCode: HTTP code to send in response
 *              message: Message to be sent in response
 * @returns {object}
 *              statusCode: HTTP code to send in response
 *              message: Message to be sent in response
 */
function getResponse(statusCode, message) {
    return {
        statusCode: statusCode,
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(message),
    }
}
