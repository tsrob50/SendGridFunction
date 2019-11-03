function Send-SendGridEmail {
  param(
    [Parameter(Mandatory = $true)]
    [String] $destEmailAddress,
    [Parameter(Mandatory = $true)]
    [String] $fromEmailAddress,
    [Parameter(Mandatory = $true)]
    [String] $subject,
    [Parameter(Mandatory = $false)]
    [string]$contentType = 'text/plain',
    [Parameter(Mandatory = $true)]
    [String] $contentBody
  )

  <#

.Synopsis
Function to send email with SendGrid

.Description
A function to send a text or HTML based email
See https://sendgrid.com/docs/API_Reference/api_v3.html for API details
This script provided as-is with no warranty. Test it before you trust it.
www.ciraltos.com

.Parameter apiKey
The SendGrid API key associated with your account

.Parameter destEmailAddress
The destination email address

.Parameter fromEmailAddress
The from email address

.Parameter subject
Email subject

.Parameter type
The content type, values are “text/plain” or “text/html”.  "text/plain" set by default

.Parameter content
The content that you'd like to send

.Example
Send-SendGridEmail

#>
  ############ Update with your SendGrid API Key ####################
  $apiKey = "Enter API Key Here"

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


# Call the function 
# Splat the input

$splat = @{
  destEmailAddress = 'address@email.net'
  fromEmailAddress = 'donotreply@my.net'
  subject          = 'Test Email'
  contentBody      = 'This is a test message sent from SendGrid'
}
Send-SendGridEmail @splat


# Sample code with HTML body
$htmlBody = @"
<table>
        <tr>
               <td align="center">This is the Header</td>
        </tr>
        <tr>
               <td align="center">Here is the content of my message</td>
        </tr>
        <tr>
               <td align="center">This is the footer</td>
        </tr>
</table>
"@


$splat2 = @{
  destEmailAddress = 'address@email.net'
  fromEmailAddress = 'donotreply@my.net'
  subject          = 'Test Email'
  contentType      = 'text/html'
  contentBody      = $htmlBody
}
Send-SendGridEmail @splat2
