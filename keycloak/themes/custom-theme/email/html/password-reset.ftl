<#-- Password reset template for the IAM Platform. -->
<#import "template.ftl" as layout>
<@layout.main>
    <h2 style="margin: 0 0 16px 0; font-size: 20px; font-weight: 600; color: #111827;">
        ${msg("passwordResetSubject")}
    </h2>
    <p style="margin: 0 0 24px 0; font-size: 15px; color: #374151; line-height: 1.6;">
        ${msg("passwordResetBodyHtml", linkExpiration)}
    </p>
    <table role="presentation" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td align="center" style="padding: 8px 0 24px 0;">
                <a href="${link}"
                   style="display: inline-block; padding: 12px 32px; background-color: #1a56db; color: #ffffff; font-size: 15px; font-weight: 600; text-decoration: none; border-radius: 6px;">
                    Reset Password
                </a>
            </td>
        </tr>
    </table>
    <p style="margin: 0; font-size: 13px; color: #6b7280; line-height: 1.5;">
        If the button above does not work, copy and paste the following URL into your browser:
        <br />
        <a href="${link}" style="color: #1a56db; word-break: break-all;">${link}</a>
    </p>
</@layout.main>
