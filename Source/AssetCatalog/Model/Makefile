FILES := AppIcon_Car.json \
		AppIcon_Mac.json \
		AppIcon_Watch.json \
		AppIcon_iOS.json \
		AppIcon_iPad.json \
		AppIcon_iPhone.json \
		ImageSet.json \
		LaunchImage_iPad_Landscape.json \
		LaunchImage_iPad_Portrait.json \
		LaunchImage_iPhone_Landscape.json \
		LaunchImage_iPhone_Portrait.json

all:
	@$(foreach json,$(FILES), \
		xxd -i $(json) > $(basename $(json)).c ; \
	)

	