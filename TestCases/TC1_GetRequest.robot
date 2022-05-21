*** Settings ***

Library     RequestsLibrary
Library     JSONLibrary
Library     Collections

*** Variables ***
${base_url}=    https://gorest.co.in/public/v2
@{json_elements}=   id  name    email   gender  status
*** Test Cases ***
Get_userInfo
    create session  testsession     ${base_url}
    ${response}=    get request  testsession    /users
    #${user_email}=      get value from json     ${response_content}     $.[0].email

    log to console  ${response.status_code}
    #log to console  ${response.content}
    #log to console  ${response.headers}
    ${response_header_value}=       get from dictionary     ${response.headers}     X-Pagination-Limit
    ${response_body}=   to json  ${response.content}
    #log to console  ${response_body}

    #validation

    #status code validation
    ${status_code}=     convert to string   ${response.status_code}
    should be equal  ${status_code}     200
    #Negative scenario
    ${negative_response_404}=    get request  testsession    /user
    ${error_code404_validation}=   convert to string   ${negative_response_404.status_code}
    should be equal  ${error_code404_validation}     404
    ${negative_response_400}=    get request  testsession    /users9a039039;s<!+>
    ${error_code400_validation}=   convert to string   ${negative_response_400.status_code}
    should be equal  ${error_code400_validation}     400


    #validate X-Pagination-Limit header value
    should be equal  ${response_header_value}       20

    #${user_email}=      get value from json     ${response_body}     $.[0].email
    #should contain  ${response_body}    tarun_lld_devar@metz.co
    #log to console      ${response_body[0]['email']}
    FOR    ${jsonValues}   IN      @{response_body}
        #log to console      ${\n}
        #log to console      ${jsonValues}
        FOR     ${item}     IN      @{json_elements}
            #Json respone validation
            should contain      ${jsonValues}   ${item}
            #Json response value validation
            should not be empty     ${jsonValues}.${item}
            #email validation
            should match regexp     ${jsonValues}.email     ([a-zA-Z0-9_.-])+@([a-zA-Z0-9])+.([a-zA-Z0-9])+
        END
    END






