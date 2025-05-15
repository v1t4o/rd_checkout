web:
	@docker-compose up web

tests:
	@docker-compose up test

quality:
	@bundle exec rubocop
