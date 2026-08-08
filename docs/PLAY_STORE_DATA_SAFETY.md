# Play Store — Data Safety form (fill this in)

Use these answers when completing the Play Console "Data safety" questionnaire
for Tidy Tank.

## Does your app collect or share any of the required user data?
YES — for advertising purposes only.

## Data types collected
- [x] Advertising ID (collected by Google AdMob SDK)

## Data types shared
- [x] Advertising ID (shared with Google AdMob / ad partners)

## Is this data collected for advertising?
YES. All collected data is used for advertising.

## Does your app collect precise location? NO
## Does your app collect health / financial / contacts / messages? NO
## Does your app collect photos / media / files? NO (game art is bundled)
## Does your app use cookies / local storage SDKs? YES (AdMob)

## Data deletion
- App provides in-app controls? The Advertising ID can be reset/opt-out via
  device settings. No account data is stored server-side.

## User data deletion / account
- No user account is created. All progress is local to the device.

## Content rating
- Questionnaire → select **Teen (13+)**.
- Reasons: no violence, no user-to-user communication, ads present, no gacha.

## Closed testing requirement (new apps)
- Before production, run a **closed test with at least 20 testers for 14 days**.
- Use the "Closed test" track in Play Console; invite testers via email list
  or Google Group.

## Reminder
- Build and upload an **AAB** (not APK). The Android export preset is in
  `android/export_presets.cfg`.
- Provide a **privacy policy URL** (host `docs/PRIVACY_POLICY.md` on GitHub
  Pages or any static host) in the Play Console.
- Integrate **UMP / Consent SDK** before showing personalized ads (EU/UK).
