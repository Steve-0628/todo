.PHONY: all frontend backend clean

all: frontend backend

frontend:
	$(MAKE) -C frontend

backend:
	cd backend && dotnet build

clean:
	$(MAKE) -C frontend clean
	cd backend && dotnet clean
