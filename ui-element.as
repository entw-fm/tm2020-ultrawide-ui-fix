namespace UIElements{
	array<UIElement@> elements;
	
	void AddElementByIdFromUILayer(string id, CGameUILayer@ layer){
		string[] frames = Regex::Search(layer.ManialinkPage, "<frame.*?id=\""+id+"\".*?>");
		if(frames.Length < 1){
			return;
		}
		string frame = frames[0];
		elements.InsertLast(UIElement(frame,layer));
	}
	
	void FixAll(){
		for(uint x = 0; x < elements.Length; ++x) {
			elements[x].FixPosition();
		}
	}
	
	void Clear(){
		while(elements.get_Length() > 0){
			elements.RemoveLast();
		}
	}
}

class UIElement{
	string _id;
	vec2 _originalPosition;
	string _frame;
	CGameUILayer@ _origin;
	
	UIElement(string frame, CGameUILayer@ origin){
		_frame = frame;
		_id = ResolveId(frame);
		_originalPosition = ResolvePosition(frame);
		@_origin = origin;
	}
	
	void FixPosition(){
		float uiShift = Helpers::GetUiShift();
		float newX;
		if(_originalPosition.x >= 0){
			newX = Helpers::sum(uiShift,_originalPosition.x);
		} else {
			newX = Helpers::sum(-uiShift,_originalPosition.x);
		}
		vec2 newPosition = vec2(newX,_originalPosition.y);
		SetPosition(newPosition);
	}
	
	void Reset(){
		SetPosition(_originalPosition);
	}
	
	void SetPosition(vec2 newPosition){
		string frameFixed = Regex::Replace(_frame, "pos=\".*?\"", "pos=\""+newPosition.x+" "+newPosition.y+"\"");
		_origin.ManialinkPage = Helpers::SpliceInFixedPart(_frame,frameFixed,_origin.ManialinkPage);
	}
	
	private string ResolveId(string frame){
		string[] idArray = Regex::Search(frame, "id=\".*?\"");
		string id = " ";
		if(idArray.Length > 0){
			id = idArray[0].SubStr(4,idArray[0].get_Length() - 5);
		}
		return id;
	}

	private vec2 ResolvePosition(string frame){
		string[] positionArray = Regex::Search(frame, "pos=\".*?\"");
		vec2 position = vec2(0,0);
		if(positionArray.Length > 0){
			string positionString = positionArray[0].SubStr(5,positionArray[0].get_Length() - 6);
			string[] positions =  positionString.Split(" ");
			float x = Text::ParseFloat(positions[0]);
			float y = Text::ParseFloat(positions[1]);
			position = vec2(x,y);
		}
		return position;
	}
}