# Clone the backend into ./BubbleBackendVapor before building images.
# Replace the URL with your own backend repository.
del-clone-repo:
	rm -rf ./BubbleBackendVapor
	git clone git@github.com:your-org/your-backend-repo.git ./BubbleBackendVapor

docker-build-prod:
	docker compose -f docker-compose-prod.yml build
	docker compose -f docker-compose-prod.yml up

docker-build-dev:
	docker compose -f docker-compose-dev.yml build
	docker compose -f docker-compose-dev.yml up &
	# Optional: expose the local port via a public tunnel for testing.
	osascript -e 'tell application "Terminal" to do script "ssh -p 443 -R0:localhost:80 tcp@a.pinggy.io"'
	osascript -e 'tell application "Terminal" to do script "ngrok http 80"'
