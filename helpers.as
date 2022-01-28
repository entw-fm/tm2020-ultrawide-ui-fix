namespace Helpers{
	//Returns how much wider the screen is than a 16:9 screen
	float GetUiShift(){

		auto viewport = cast<CDx11Viewport>(GetApp().Viewport);

		//Get screen dimensions
		float screenWidth = viewport.cPixelSwapX;
		float screenHeight = viewport.cPixelSwapY;
	
		//Calculate new edge based on dimensions
		return ((screenWidth / (screenHeight / 9)) * 10) - 160;
	}
	
	float sum(float x, float y){
		return x + y;
	}
	
	//Replaces first occurance of a string, the normal string.Replace method doesn't seem to work for me so i'm just doing it like this
	string SpliceInFixedPart(string oldPart, string fixedPart, string page){
		string[] pageParts = page.Split(oldPart,2);
		return pageParts[0] + fixedPart + pageParts[1];
	}
}