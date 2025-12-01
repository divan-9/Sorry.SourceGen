.PHONY: build test publish ci-publish pack-attributes pack-sourcegen

# Variables
PROJECT_NAME = Sorry.SourceGens
ATTRIBUTES_PROJECT_NAME = Sorry.SourceGens.Attributes
PROJECT_PATH = $(PROJECT_NAME)/$(PROJECT_NAME).csproj
ATTRIBUTES_PROJECT_PATH = $(ATTRIBUTES_PROJECT_NAME)/$(ATTRIBUTES_PROJECT_NAME).csproj
VERSION ?= 1.0.0

build:
	@dotnet restore
	@dotnet build --no-restore --configuration Release

test: build
	@dotnet test --no-build --configuration Release --verbosity normal

pack-attributes:
	@dotnet pack $(ATTRIBUTES_PROJECT_PATH) --no-build -c Release -p:PackageVersion=$(VERSION)

pack-sourcegen: pack-attributes
	@dotnet pack $(PROJECT_PATH) --no-build -c Release -p:PackageVersion=$(VERSION)

publish: test pack-sourcegen pack-attributes
	@dotnet nuget push $(ATTRIBUTES_PROJECT_NAME)/bin/Release/$(ATTRIBUTES_PROJECT_NAME).$(VERSION).nupkg \
	 -k $(NUGET_KEY) -s https://api.nuget.org/v3/index.json --skip-duplicate
	@dotnet nuget push $(PROJECT_NAME)/bin/Release/$(PROJECT_NAME).$(VERSION).nupkg \
	 -k $(NUGET_KEY) -s https://api.nuget.org/v3/index.json --skip-duplicate

ci-publish:
	@$(MAKE) publish VERSION=$(REF_NAME)