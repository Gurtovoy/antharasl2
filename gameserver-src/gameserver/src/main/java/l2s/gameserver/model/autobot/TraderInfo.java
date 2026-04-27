package l2s.gameserver.model.autobot;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class TraderInfo
{
	private static final Gson GSON = new Gson();
	private static final Type ITEM_LIST_TYPE = new TypeToken<List<TradeItemConfig>>(){}.getType();

	private int id;
	private int botId;
	private int zoneId;
	private int slotIndex = -1;
	private String tradeType = "sell";
	private String storeName = "Trade Bot";
	private String itemsJson;
	private boolean isActive;

	public TraderInfo()
	{
	}

	public int getId()
	{
		return id;
	}

	public void setId(int id)
	{
		this.id = id;
	}

	public int getBotId()
	{
		return botId;
	}

	public void setBotId(int botId)
	{
		this.botId = botId;
	}

	public int getZoneId()
	{
		return zoneId;
	}

	public void setZoneId(int zoneId)
	{
		this.zoneId = zoneId;
	}

	public int getSlotIndex()
	{
		return slotIndex;
	}

	public void setSlotIndex(int slotIndex)
	{
		this.slotIndex = slotIndex;
	}

	public String getTradeType()
	{
		return tradeType;
	}

	public void setTradeType(String tradeType)
	{
		this.tradeType = tradeType;
	}

	public String getStoreName()
	{
		return storeName;
	}

	public void setStoreName(String storeName)
	{
		this.storeName = storeName;
	}

	public String getItemsJson()
	{
		return itemsJson;
	}

	public void setItemsJson(String itemsJson)
	{
		this.itemsJson = itemsJson;
	}

	public boolean isActive()
	{
		return isActive;
	}

	public void setActive(boolean active)
	{
		this.isActive = active;
	}

	public List<TradeItemConfig> getItems()
	{
		if(itemsJson == null || itemsJson.isEmpty())
		{
			return Collections.emptyList();
		}
		try
		{
			List<TradeItemConfig> items = GSON.fromJson(itemsJson, ITEM_LIST_TYPE);
			return items != null ? items : Collections.emptyList();
		}
		catch(Exception e)
		{
			return Collections.emptyList();
		}
	}

	public void setItems(List<TradeItemConfig> items)
	{
		this.itemsJson = GSON.toJson(items);
	}

	public static class TradeItemConfig
	{
		private int itemId;
		private long count;
		private long price;

		public TradeItemConfig()
		{
		}

		public TradeItemConfig(int itemId, long count, long price)
		{
			this.itemId = itemId;
			this.count = count;
			this.price = price;
		}

		public int getItemId()
		{
			return itemId;
		}

		public void setItemId(int itemId)
		{
			this.itemId = itemId;
		}

		public long getCount()
		{
			return count;
		}

		public void setCount(long count)
		{
			this.count = count;
		}

		public long getPrice()
		{
			return price;
		}

		public void setPrice(long price)
		{
			this.price = price;
		}
	}
}
