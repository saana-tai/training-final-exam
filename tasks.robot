*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Archive
Library           RPA.Browser
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Tables
Task Teardown     Close All Browsers

*** Variables ***
${RECEIPTS_DIR}=    ${OUTPUT_DIR}${/}receipts

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Create a ZIP file of the receipts

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    ${csv_file_name}=    Set Variable    orders.csv
    Download    https://robotsparebinindustries.com/${csv_file_name}    overwrite=True
    ${orders}=    Read Table From Csv    ${csv_file_name}
    [Return]    ${orders}

Close the annoying modal
    Click Element When Visible    css:.modal .btn

Fill the form
    [Arguments]    ${row}
    Select From List By Value    id:head    ${row}[Head]
    Select Radio Button    body    ${row}[Body]
    Input Text    css:input[type="number"]    ${row}[Legs]
    Input Text    id:address    ${row}[Address]

Preview the robot
    Click Button    id:preview

Submit the order
    Wait Until Keyword Succeeds    5x    1s    Complete order

Complete order
    Click Button    id:order
    Wait Until Element Is Visible    id:receipt

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    ${pdf}=    Set Variable    ${RECEIPTS_DIR}${/}robot-${order_number}.pdf
    Html To Pdf    ${receipt_html}    ${pdf}
    [Return]    ${pdf}

Take a screenshot of the robot
    [Arguments]    ${order_number}
    ${screenshot}=    Set Variable    ${RECEIPTS_DIR}${/}robot-${order_number}.png
    Screenshot    id:robot-preview-image    ${screenshot}
    [Return]    ${screenshot}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf Document    ${pdf}
    Add Image To Pdf    ${screenshot}    target=${pdf}
    Close Pdf Document    ${pdf}

Go to order another robot
    Click Button    id:order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${RECEIPTS_DIR}    ${OUTPUT_DIR}${/}receipts.zip
