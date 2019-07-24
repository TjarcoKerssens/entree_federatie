# Entree Federatie Native Login 
Deze repository bevat twee applicaties die als referentie gebruikt kunnen worden om inloggen in een native iOS applicatie mogelijk te maken. Er is ook een voorbeeld voor een native Android Applicatie.

## Werking
De applicaties gebruiken een WebView om het login scherm te tonen. Vervolgens worden de cookies uit deze view gehaald en in de Keychain opgeslagen. Op het moment dat je de applicatie opstart, wordt eerst getest of de Keychain een geldige sessie bevat. Mocht dit zo zijn, dan gaat de applicatie meteen naar het hoofdscherm. 

### Referentie applicatie
De [referentie applicatie](https://referentie.entree.kennisnet.nl/) is een simpele applicatie die wat eigenschappen van de ingelogde gebruiker toont. In dit voorbeeld wordt deze applicatie gebruikt om in te loggen en vervolgens de eigenschappen uit de applicatie te halen om in de native applicatie te tonen. 

### WikiWijs applicatie
Voor WikiWijs is de implementatie enkel een WebView. Dit is om de SSO functionaliteit te tonen. Als er is ingelogd in de Referentie Applicatie, hoeft er in deze applicatie niet opnieuw ingelogd te worden. De sessie wordt gedeeld via Keychain. Andersom werkt het ook, inloggen in de WikiWijs applicatie zorgt ervoor dat de gebruiker ook ingelogd is bij de Referentie applicatie. 

## Gebruik
De classes in de mappen `Data` en `Extensions` kunnen gebruikt worden om een eigen applicatie te realiseren. Hiervoor zijn een aantal stappen nodig: 

1. De applicatie heeft een webview nodig. Zie `LoginViewController` als voorbeeld
2. De applicatie moet Keychain Sharing aanzetten: `Targets > Target_name > Capabilities > Keychain Sharing`.
3. De Keychain Group moet gelijk gezet worden voor de applicaties. Gebruik `kennisnet.Entree-Federatie`.
4. Bij alle applicaties moet `info.plist` een key-value pair bevatten met als key `AccesGroup` en als value `$(AppIdentifierPrefix)kennisnet.Entree-Federatie`

Let er op dat de AppIdentifierPrefix hetzelfde moet zijn voor alle applicaties. Dit betekent dat alle applicaties door hetzelfde Apple Developer account/team gesigned moeten worden. 
