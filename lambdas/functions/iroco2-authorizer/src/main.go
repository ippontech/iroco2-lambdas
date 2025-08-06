package main

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"os"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/golang-jwt/jwt/v5"
)

var pemKey = os.Getenv("IROCO2_KMS_IDENTITY_PUBLIC_KEY")

func handler(event events.APIGatewayCustomAuthorizerRequest) (events.APIGatewayCustomAuthorizerResponse, error) {
	token := event.AuthorizationToken
	if token == "" {
		return events.APIGatewayCustomAuthorizerResponse{}, errors.New("no token provided")
	}

	if !isValidToken(token) {
		policy := generatePolicy("user", "Deny", event.MethodArn)
		return policy, nil
	}

	policy := generatePolicy("user", "Allow", event.MethodArn)
	return policy, nil
}

func loadPublicKey(pemKey string) (*rsa.PublicKey, error) {
	block, _ := pem.Decode([]byte(pemKey))
	if block == nil {
		return nil, errors.New("échec du décodage de la clé publique PEM")
	}

	pubKey, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("erreur lors de l'analyse de la clé publique: %v", err)
	}

	rsaPubKey, ok := pubKey.(*rsa.PublicKey)
	if !ok {
		return nil, fmt.Errorf("la clé publique n'est pas de type RSA")
	}

	return rsaPubKey, nil
}

func isValidToken(token string) bool {
	if token == "" || !strings.HasPrefix(token, "Bearer ") {
		return false
	}
	token = strings.TrimPrefix(token, "Bearer ")

	publicKey, err := loadPublicKey(pemKey)
	if err != nil {
		return false
	}

	parsedToken, err := jwt.Parse(token, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, fmt.Errorf("méthode de signature inattendue: %v", token.Header["alg"])
		}
		return publicKey, nil
	})

	if err != nil {
		return false
	}

	return parsedToken.Valid
}

func generatePolicy(principalID, effect, resource string) events.APIGatewayCustomAuthorizerResponse {
	return events.APIGatewayCustomAuthorizerResponse{
		PrincipalID: principalID,
		PolicyDocument: events.APIGatewayCustomAuthorizerPolicy{
			Version: "2012-10-17",
			Statement: []events.IAMPolicyStatement{
				{
					Action:   []string{"execute-api:Invoke"},
					Effect:   effect,
					Resource: []string{resource},
				},
			},
		},
	}
}

func main() {
	lambda.Start(handler)
}
