*** Settings ***
Documentation    Suite description

Library     RequestsLibrary
Library     JSONLibrary
Library     Collections
Library     LibFiles/util.py

*** Keywords ***

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