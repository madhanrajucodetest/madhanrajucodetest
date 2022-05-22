*** Settings ***

Library     RequestsLibrary
Library     JSONLibrary
Library     Collections

*** Variables ***
${base_url}=    https://gorest.co.in/public/v2
@{json_elements}=   id  name    email   gender  status
${access_token}=    Bearer dd71a83f4d33aec0f179fdf1476c0d1d6e1e82e6e7050432de18eb6fe3fade7e
${access_token_invalid}=    Bearer 0071a83f4d33aec0f179fdf1476c0d1d6e1e82e6e7050432de18eb6fe3fade7e
*** Test Cases ***
TC1:Get_userInfo
    create session  testsession     ${base_url}
    ${response}=    GET On Session  testsession    /users
    #${user_email}=      get value from json     ${response_content}     $.[0].email

    log to console  ${response.status_code}
    ${response_header_value}=       get from dictionary     ${response.headers}     X-Pagination-Limit
    ${response_body}=   to json  ${response.content}

    #validation

    #status code 200 validation
    ${status_code}=     convert to string   ${response.status_code}
    should be equal  ${status_code}     200
    #Negative scenario - 404
    ${negative_response_404}=    get request  testsession    /user
    ${error_code404_validation}=   convert to string   ${negative_response_404.status_code}
    should be equal  ${error_code404_validation}     404
    #Validate Status code 400
    ${negative_response_400}=    get request  testsession    /users9a039039;s<!+>
    ${error_code400_validation}=   convert to string   ${negative_response_400.status_code}
    should be equal  ${error_code400_validation}     400


    #validate X-Pagination-Limit header value
    should be equal  ${response_header_value}       20

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
TC2:Create User
    create session  testsession     ${base_url}
    ${header}=  create dictionary       Authorization=${access_token}   Content-Type=application/json
    ${numbers}=    Evaluate    random.sample(range(1, 110000), 4)    random
    ${post_data}=    create dictionary      name=Raj${numbers[0]}       gender=male     email=test${numbers[0]}@gmail.com       status=active
    ${response}=    post request    testsession   /users  data=${post_data}    headers=${header}
    ${response_body}=   convert to string  ${response.content}
    log to console  ${response.status_code}
    log to console  ${response.content}
    #log to console  ${response_body}
    ${json_response}=   to json      ${response.content}
    ${customer_id}=     get value from json  ${json_response}       $.id
    set suite variable      ${customer_id}
    log to console      ${customer_id}

    #Validate Status code of Post call
    ${response_code}=   convert to string       ${response.status_code}
    should be equal     ${response_code}    201

    #validate invalid Authentication code - 401
    ${header}=  create dictionary       Authorization=${access_token_invalid}   Content-Type=application/json
    ${numbers}=    Evaluate    random.sample(range(1, 110000), 4)    random
    ${post_data}=    create dictionary      name=Raj${numbers[0]}       gender=male     email=test${numbers[0]}@gmail.com       status=active
    ${response}=    post request    testsession   /users  data=${post_data}    headers=${header}
    ${response_code}=   convert to string       ${response.status_code}
    should be equal     ${response_code}    401

    #validate invalid Authentication code - 422 -- Data validation failed
    ${header}=  create dictionary       Authorization=${access_token}   Content-Type=application/json
    ${numbers}=    Evaluate    random.sample(range(1, 110000), 4)    random
    ${post_data}=    create dictionary      name=Raj${numbers[0]}   gender=male     email=test${numbers[0]}@gmail.com<script>alert(1)</script>       status=active
    ${response}=    post request    testsession   /users  data=${post_data}    headers=${header}
    ${response_code}=   convert to string       ${response.status_code}
    should be equal     ${response_code}    422

TC3:Update User Details
    create session  testsession     ${base_url}
    ${header}=  create dictionary       Authorization=${access_token}   Content-Type=application/json
    ${numbers}=    Evaluate    random.sample(range(1, 110000), 4)    random
    ${post_data}=    create dictionary      name=Raj${numbers[0]}       gender=male     email=test${numbers[0]}@gmail.com       status=active
    ${response}=    patch request   testsession   /users/${customer_id}[0]  data=${post_data}    headers=${header}
    ${response_body}=   convert to string  ${response.content}
    log to console  ${response.status_code}
    log to console  ${response.content}
    log to console  ${customer_id}

    #Validate Status code of Patch request
    ${response_code}=   convert to string       ${response.status_code}
    should be equal     ${response_code}    200

    #Validation -- -ve scenario validate error status code 404
    ${response}=    patch request   testsession   /users/abc  data=${post_data}    headers=${header}
    ${response_code}=   convert to string       ${response.status_code}
    should be equal     ${response_code}    404

    #Validation error message handling
    ${response_body}=   convert to string  ${response.content}
    should contain  ${response_body}    Resource not found

    #validate -- -ve invalid auth code -- 401
    ${header}=  create dictionary       Authorization=${access_token_invalid}   Content-Type=application/json
    ${numbers}=    Evaluate    random.sample(range(1, 110000), 4)    random
    ${post_data}=    create dictionary      name=Raj${numbers[0]}       gender=male     email=test${numbers[0]}@gmail.com       status=active
    ${response}=    patch request   testsession   /users/${customer_id}[0]  data=${post_data}    headers=${header}
    ${response_body}=   convert to string  ${response.content}

    #Validate Status code of Patch request
    ${response_code}=   convert to string       ${response.status_code}
    should be equal     ${response_code}    401

TC4:Delete User
    create session  testsession     ${base_url}
    ${header}=  create dictionary       Authorization=${access_token}   Content-Type=application/json
    #${numbers}=    Evaluate    random.sample(range(1, 110000), 4)    random
    #${post_data}=    create dictionary      name=Raj${numbers[0]}       gender=male     email=test${numbers[0]}@gmail.com       status=active
    ${response}=    delete request  testsession   /users/${customer_id}[0]    headers=${header}
    ${response_body}=   convert to string  ${response.content}
    log to console  ${response.status_code}
    log to console  ${response.content}

    #Validate Status code of Patch request
    ${response_code}=   convert to string       ${response.status_code}
    should be equal     ${response_code}    204

    #Validate invalid Auth - -ve scenario -- 401
    ${header}=  create dictionary       Authorization=${access_token_invalid}   Content-Type=application/json
    #${numbers}=    Evaluate    random.sample(range(1, 110000), 4)    random
    #${post_data}=    create dictionary      name=Raj${numbers[0]}       gender=male     email=test${numbers[0]}@gmail.com       status=active
    ${response}=    delete request  testsession   /users/${customer_id}[0]    headers=${header}
    ${response_body}=   convert to string  ${response.content}
    log to console  ${response.status_code}
    log to console  ${response.content}

    #Validate Status code of Patch request
    ${response_code}=   convert to string       ${response.status_code}
    should be equal     ${response_code}    401