package l2s.gameserver.model.autobot;

import java.util.ArrayList;
import java.util.List;

public class SocialPreferences
{
	private TownAction townAction = TownAction.NONE;
	private boolean chatEnabled = false;
	private List<String> chatMessages = new ArrayList<>();

	public SocialPreferences()
	{
	}

	public TownAction getTownAction()
	{
		return townAction;
	}

	public void setTownAction(TownAction townAction)
	{
		this.townAction = townAction;
	}

	public boolean isChatEnabled()
	{
		return chatEnabled;
	}

	public void setChatEnabled(boolean chatEnabled)
	{
		this.chatEnabled = chatEnabled;
	}

	public List<String> getChatMessages()
	{
		return chatMessages;
	}

	public void setChatMessages(List<String> chatMessages)
	{
		this.chatMessages = chatMessages;
	}
}
