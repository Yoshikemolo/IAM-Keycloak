<#-- Custom email HTML template for the IAM Platform.
     Provides a clean, responsive layout that works across major email clients.
     Uses inline styles for maximum compatibility. -->
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${realmName} - ${subject!""}</title>
</head>
<body style="margin: 0; padding: 0; background-color: #f9fafb; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;">
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%" style="background-color: #f9fafb;">
        <tr>
            <td align="center" style="padding: 40px 20px;">
                <table role="presentation" cellpadding="0" cellspacing="0" width="600" style="max-width: 600px; width: 100%;">
                    <!-- Header -->
                    <tr>
                        <td align="center" style="padding: 0 0 24px 0;">
                            <h1 style="margin: 0; font-size: 24px; font-weight: 700; color: #1a56db;">
                                ${realmName!"IAM Platform"}
                            </h1>
                        </td>
                    </tr>
                    <!-- Content Card -->
                    <tr>
                        <td style="background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 32px;">
                            <#nested>
                        </td>
                    </tr>
                    <!-- Footer -->
                    <tr>
                        <td align="center" style="padding: 24px 0 0 0;">
                            <p style="margin: 0; font-size: 12px; color: #9ca3af; line-height: 1.5;">
                                This is an automated message from ${realmName!"IAM Platform"}.
                                <br />
                                Please do not reply to this email.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
