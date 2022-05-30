*** Settings ***
Documentation    Suite description

Library     RequestsLibrary
Library     JSONLibrary
Library     Collections
Library     LibFiles/util.py

*** Keywords ***

Validate_Response_Status_Code
    [Documentation]     validate API call status code
    [Arguments]     ${response}    ${status_code_to_check}
    ${status_code}=     convert to string   ${response.status_code}
    should be equal  ${status_code}     ${status_code_to_check}

Validate_Json_Response
    [Documentation]     validate API JSon response
    [Arguments]     ${response_body}    ${json_elements}
    log to console  ${json_elements}
    FOR     ${jsonValues}   IN      @{response_body}
        #log to console      ${\n}
        #log to console      ${jsonValues}
        FOR     ${item}     IN      @{json_elements}
            #Json respone validation
            should contain      ${jsonValues}   ${item}
            #Json response value validation
            should not be empty     ${jsonValues}.${item}
            #email validation
            ${email_validation_results}=    validate_Email      ${jsonValues}.email
            should be equal as strings      ${email_validation_results}      valid
        END
    END