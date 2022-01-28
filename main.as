//Regular elements where we just need to adjust the position
string[] frameIdsToFix = {
	"Race_RespawnHelper",
	"Race_LapsCounter",
	"Race_Record",
	"Race_WarmUp",
	"Race_TimeGap",
	"Race_Countdown",
	"Race_BestRaceViewer",
	"Race_DisplayMessage",
	"frame-medal",
	"frame-content",
	"Royal_TeamScore",
	"Royal_RespawnHelper",
	"Royal_LiveRanking",
	"Royal_FinishFeed",
	"frame-players"
};

string[] clippingIdsToFix = {
	"frame-global",
	"clip-medal-banner"
};

uint oldLength;
bool isOn = true;

void Main()
{
	while(true){
		//Only apply fixes if the plugin is on and we're actually in widescreen
		if(isOn && Helpers::GetUiShift() > 1){
			ApplyFix();
		}
		yield();
	}
}

void RenderMenu()
{
	//Todo properly do icon 🤔
	if (UI::MenuItem("\\$f9f\\$z Ultrawide UI fix", "", isOn)) {
		isOn = !isOn;
	}
}

void ApplyFix(){

	auto network = cast<CTrackManiaNetwork>(GetApp().Network);
	if(network is null){
		return;
	}
	auto playground = cast<CGameManiaAppPlayground>(network.ClientManiaAppPlayground);
	if(playground is null){
		return;
	}
	
	//Only fix UI if the UI changed
	if(playground.UILayers.Length != oldLength){
		UIElements::Clear();
		FindAndFixRegularElements(playground.UILayers);
		FindAndFixGlobalClippingFrames(playground.UILayers);
		FindAndFixPostionChangesInCode(playground.UILayers);
		FindAndFixAnimations(playground.UILayers);
		FindAndFixRoyalWaitingScreen(playground.UILayers);
		oldLength = playground.UILayers.Length;
	}
}

void FindAndFixRegularElements(MwFastBuffer<CGameUILayer@> layers){
	for(uint x = 0; x < layers.Length; ++x) {
		auto layer = layers[x];
		for(uint y = 0; y < frameIdsToFix.Length; ++y) {
			UIElements::AddElementByIdFromUILayer(frameIdsToFix[y],layer);
		}
	}
	UIElements::FixAll();
}

//Really scuffed due to severe lack of ids on frames
void FindAndFixRoyalWaitingScreen(MwFastBuffer<CGameUILayer@> layers){
	for(uint x = 0; x < layers.Length; ++x) {
		auto layer = layers[x];
		auto animRightRegex = Regex::SearchAll(layer.ManialinkPage, "<frame.*?id=\"frame-visibility-anim-right\".*?>(.|\\s)*?>");
		auto animLeftRegex = Regex::SearchAll(layer.ManialinkPage, "<frame.*?id=\"frame-eliminations\".*?>");
		auto clipRegex = Regex::SearchAll(layer.ManialinkPage, "<frame z-index=\"2\" size=\"320 180\" halign=\"center\" valign=\"center\">");
		for(uint y = 0; y < clipRegex.get_Length(); ++y) {
			string[] regexThing = clipRegex[y];
			if(regexThing.Length < 1){
				continue;
			}
			string clip = regexThing[0];
			
			//Resolve size
			string[] sizeArray = Regex::Search(clip, "size=\".*?\"");
			if(sizeArray.Length < 1){
				continue;
			}
			
			string sizeString = sizeArray[0].SubStr(6,sizeArray[0].get_Length() - 7);
			string[] sizes =  sizeString.Split(" ");
			float sizeX = Text::ParseFloat(sizes[0]);
			float sizeY = Text::ParseFloat(sizes[1]);
			float shift = Helpers::GetUiShift();
			sizeX = Math::Ceil(sizeX + (shift * 2));
			vec2 size = vec2(sizeX,sizeY);
			
			string clipFixed = Regex::Replace(clip, "size=\".*?\"", "size=\""+size.x+" "+size.y+"\"");
			layer.ManialinkPage = Helpers::SpliceInFixedPart(clip,clipFixed,layer.ManialinkPage);
		}
		for(uint y = 0; y < animRightRegex.get_Length(); ++y) {
			string[] regexThing = animRightRegex[y];
			if(regexThing.Length < 1){
				continue;
			}
			string anim = regexThing[0];
			print(anim);
			string[] positionArray = Regex::Search(anim, "frame pos=\".*?\""); //Get the pos without the id
			if(positionArray.Length > 0){
					string positionString = positionArray[0].SubStr(11,positionArray[0].get_Length() - 12);
					string[] positions =  positionString.Split(" ");
					float posX = Text::ParseFloat(positions[0]);
					float posY = Text::ParseFloat(positions[1]);
				if(posX < 0){
					float newPos = Helpers::sum(-Helpers::GetUiShift(),posX);
					string animFixed = Regex::Replace(anim,"frame pos=\".*?\"", "frame pos=\""+newPos+" "+posY+"\"");
					layer.ManialinkPage = Helpers::SpliceInFixedPart(anim,animFixed,layer.ManialinkPage);
					print(animFixed);
				}
				if(posX > 0){
					float newPos = Helpers::sum(Helpers::GetUiShift(),posX);
					string animFixed = Regex::Replace(anim,"frame pos=\".*?\"", "frame pos=\""+newPos+" "+posY+"\"");
					layer.ManialinkPage = Helpers::SpliceInFixedPart(anim,animFixed,layer.ManialinkPage);
					print(animFixed);
				}
			}
		}
		for(uint y = 0; y < animLeftRegex.get_Length(); ++y) {
			string[] regexThing = animLeftRegex[y];
			if(regexThing.Length < 1){
				continue;
			}
			string anim = regexThing[0];
			print(anim);
			string[] positionArray = Regex::Search(anim, "pos=\".*?\"");
			if(positionArray.Length > 0){
					string positionString = positionArray[0].SubStr(5,positionArray[0].get_Length() - 6);
					string[] positions =  positionString.Split(" ");
					float posX = Text::ParseFloat(positions[0]);
					print(posX);
					float posY = Text::ParseFloat(positions[1]);
				if(posX < 0){
					float newPos = Helpers::sum(-Helpers::GetUiShift(),posX);
					string animFixed = Regex::Replace(anim,"pos=\".*?\"", "pos=\""+newPos+" "+posY+"\"");
					layer.ManialinkPage = Helpers::SpliceInFixedPart(anim,animFixed,layer.ManialinkPage);
					print(animFixed);
				}
				if(posX > 0){
					float newPos = Helpers::sum(Helpers::GetUiShift(),posX);
					string animFixed = Regex::Replace(anim,"pos=\".*?\"", "pos=\""+newPos+" "+posY+"\"");
					layer.ManialinkPage = Helpers::SpliceInFixedPart(anim,animFixed,layer.ManialinkPage);
					print(animFixed);
				}
			}
		}
	}
}

//TODO changes loads of animations that i don't know if they should be changed
void FindAndFixAnimations(MwFastBuffer<CGameUILayer@> layers){
	for(uint x = 0; x < layers.Length; ++x) {
		auto layer = layers[x];
		auto animationRegex = Regex::SearchAll(layer.ManialinkPage, "\"<a pos=\\\\\".*?\\\\\" \\/>\"");
		for(uint y = 0; y < animationRegex.get_Length(); ++y) {
			string[] regexThing = animationRegex[y];
			if(regexThing.Length < 1){
				continue;
			}
			string animation = regexThing[0];
			string[] positionArray = Regex::Search(animation, "pos=\\\\\".*?\\\\\"");
			if(positionArray.Length > 0){
				
				string positionString = positionArray[0].SubStr(6,positionArray[0].get_Length() - 8);
				string[] positions =  positionString.Split(" ");
				float posX = Text::ParseFloat(positions[0]);
				string posY = positions[1];
				if(posX < -140){
					float newPos = Helpers::sum(-Helpers::GetUiShift(),posX);
					string animationFixed = Regex::Replace(animation, "pos=\\\\\".*?\\\\\"", "pos=\\\""+newPos+" "+posY+"\\\"");
					layer.ManialinkPage = Helpers::SpliceInFixedPart(animation,animationFixed,layer.ManialinkPage);
				}
				if(posX > 140){
					float newPos = Helpers::sum(Helpers::GetUiShift(),posX);
					string animationFixed = Regex::Replace(animation, "pos=\\\\\".*?\\\\\"", "pos=\\\""+newPos+" "+posY+"\\\"");
					layer.ManialinkPage = Helpers::SpliceInFixedPart(animation,animationFixed,layer.ManialinkPage);
				}
			}
		}
	}
}

void FindAndFixPostionChangesInCode(MwFastBuffer<CGameUILayer@> layers){
	for(uint x = 0; x < layers.Length; ++x) {
		auto layer = layers[x];
		auto codePositionChangesRegex = Regex::SearchAll(layer.ManialinkPage, "RelativePosition_V3 = <.*?>");
		for(uint y = 0; y < codePositionChangesRegex.get_Length(); ++y) {
			string[] regexThing = codePositionChangesRegex[y];
			if(regexThing.Length < 1){
				continue;
			}
			string codePositionChange = regexThing[0];
			string position = Regex::Search(codePositionChange, "<.*?,")[0]; //Get position
			string test1 = position;
			position = position.SubStr(1,position.get_Length() - 2);
			string test2 = position;
			float posX = Text::ParseFloat(position);
			if(posX < -140){
			    float newPos = Helpers::sum(-Helpers::GetUiShift(),posX);
				string codePositionChangeFixed = Regex::Replace(codePositionChange, "<.*?,", "<"+newPos+", ");
				layer.ManialinkPage = Helpers::SpliceInFixedPart(codePositionChange,codePositionChangeFixed,layer.ManialinkPage);
			}
			if(posX > 140){
				float newPos = Helpers::sum(Helpers::GetUiShift(),posX);
				string codePositionChangeFixed = Regex::Replace(codePositionChange, "<.*?,", "<"+newPos+", ");
				layer.ManialinkPage = Helpers::SpliceInFixedPart(codePositionChange,codePositionChangeFixed,layer.ManialinkPage);
			}
		}
	}
}

void FindAndFixGlobalClippingFrames(MwFastBuffer<CGameUILayer@> layers){
	for(uint x = 0; x < layers.Length; ++x) {
		auto layer = layers[x];
		for(uint y = 0; y < clippingIdsToFix.Length; ++y) {
			string[] frames = Regex::Search(layer.ManialinkPage, "<frame.*?id=\""+clippingIdsToFix[y]+"\".*?>");
			if(frames.Length < 1){
				continue;
			}
			string frame = frames[0];
			
			//Resolve size
			string[] sizeArray = Regex::Search(frame, "size=\".*?\"");
			if(sizeArray.Length < 1){
				continue;
			}
			
			string sizeString = sizeArray[0].SubStr(6,sizeArray[0].get_Length() - 7);
			string[] sizes =  sizeString.Split(" ");
			float sizeX = Text::ParseFloat(sizes[0]);
			float sizeY = Text::ParseFloat(sizes[1]);
			float shift = Helpers::GetUiShift();
			sizeX = Math::Ceil(sizeX + (shift * 2));
			vec2 size = vec2(sizeX,sizeY);
			
			string frameFixed = Regex::Replace(frame, "size=\".*?\"", "size=\""+size.x+" "+size.y+"\"");
			layer.ManialinkPage = Helpers::SpliceInFixedPart(frame,frameFixed,layer.ManialinkPage);
		}
	}
}