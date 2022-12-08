function Send-SendGridEmail {
    <#
    .SYNOPSIS
    Function to send email with Twilio SendGrid
    
    .DESCRIPTION
    A function to send a text or HTML based email with PowerShell and SendGrid.
    See https://docs.sendgrid.com/api-reference/mail-send/mail-send for API details.
    Update the API key and from address in the function before using.
    This script provided as-is with no warranty. Test it before you trust it.
    www.ciraltos.com
       
    .PARAMETER destEmailAddress
    The destination email address.
       
    .PARAMETER subject
    The subject of the email.
    
    .PARAMETER contentType
    The content type, values are “text/plain” or “text/html”.  "text/plain" set by default.
    
    .PARAMETER contentBody
    The HTML or plain text content that of the email.

    .NOTES
    Version:        2.0
    Author:         Travis Roberts
    Creation Date:  12/1/2022
    Purpose/Change: Update for latest release of Twilio SendGrid
    ****   Update the API key and from email address with matching settings from SendGrid  ****
    ****   From address must be validated to before email delivery                         ****
    ****   This script provided as-is with no warranty. Test it before you trust it.       ****
    
    .Example
    See my YouTube channel at http://www.youtube.com/c/TravisRoberts or https://www.ciraltos.com for details.
    #>

    param(
        [Parameter(Mandatory = $true)]
        [String] $destEmailAddress,
        [Parameter(Mandatory = $true)]
        [String] $subject,
        [Parameter(Mandatory = $false)]
        [string]$contentType = 'text/plain',
        [Parameter(Mandatory = $true)]
        [String] $contentBody
    )

    ############ Update with your SendGrid API Key and Verified Email Address ####################
    $apiKey = "<SENDGRID_API_KEY>"
    $fromEmailAddress = "<VERIFIED_EMAIL_ADDRESS>"
  
    $headers = @{
        'Authorization' = 'Bearer ' + $apiKey
        'Content-Type'  = 'application/json'
    }
  
    $body = @{
        personalizations = @(
            @{
                to = @(
                    @{
                        email = $destEmailAddress
                    }
                )
            }
        )
        from             = @{
            email = $fromEmailAddress
        }
        subject          = $subject
        content          = @(
            @{
                type  = $contentType
                value = $contentBody
            }
        )
    }
  
    try {
        $bodyJson = $body | ConvertTo-Json -Depth 4
    }
    catch {
        $ErrorMessage = $_.Exception.message
        write-error ('Error converting body to json ' + $ErrorMessage)
        Break
    }
  
    try {
       Invoke-RestMethod -Uri https://api.sendgrid.com/v3/mail/send -Method Post -Headers $headers -Body $bodyJson 
    }
    catch {
        $ErrorMessage = $_.Exception.message
        write-error ('Error with Invoke-RestMethod ' + $ErrorMessage)
        Break
    }

}
  
  
# Examples, call the function using splat to pass in parameters:

# Sample code with plain text
$splat = @{
    destEmailAddress = '<To_Email_Address>'
    subject          = 'Test Email'
    contentBody      = 'This is a test message sent from SendGrid'
}
Send-SendGridEmail @splat
  
  
# Sample code with HTML body
$htmlBody = @"
<table>
        <tr>
            <header>
                <h1 align="center">This is the Header</h1>
            </header>
        <tr>
            <td align="center">Here is the content of my message</td>
        </tr>
        <tr>
            <td align="center">This is the footer</td>
        </tr>
</table>
"@

$splat = @{
    destEmailAddress = '<To_Email_Address>'
    subject          = 'Test Email'
    contentType      = 'text/html'
    contentBody      = $htmlBody
}
Send-SendGridEmail @splat
