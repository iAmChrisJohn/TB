# This script creates volumetric weighted exponential moving averages based on the high and low values read from market data.

# Function to create an exponential weighting factor
def exponentialWeightingFactor(iterations, strength)
  expo_weighting_sum = 0
  i = 0
  iterations.times do
    expo_weighting_sum += Math.exp(-(i/strength))
    i+=1
  end
  return expo_weighting_sum
end

# Function to create average
def averageOf(raw_data, rdcs, rdrs, index) #raw_data must be two-dimensional array, index must be integer. index is meant to reference the column of the 2-D array, i is supposed to cycle down the rows.
  working_data = Array.new(rdcs){Array.new(rdrs)}
  working_data = raw_data
  i = 0
  sum = 0
  rdcs.times do
    sum += working_data[i][index]
    i += 1
  end
  avg = sum/rdcs
  return avg
end

# Function to create exponential weighted sum
def exponentialWeightedSum(raw_data, rdcs, rdrs, price_index, time_strength) #raw_data must be two-dimensional array, index must be integer
  working_data = Array.new(rdcs){Array.new(rdrs)}
  working_data = raw_data
  i = 0
  exponential_weighted_sum = 0
  rdcs.times do
    exponential_weighted_sum += (working_data[i][price_index])*Math.exp(-(i/time_strength))
    i += 1
  end
  return exponential_weighted_sum
end

# Function to create volume weighting factor
def volumeWeightingFactor(raw_data, rdcs, rdrs, index, volume_index, volume_strength)
  working_data = Array.new(rdcs){Array.new(rdrs)}
  working_data = raw_data
  avg = averageOf(working_data, rdcs, rdrs, volume_index)
  volume_weighting_factor = Math.exp(((volume_strength*working_data[index][volume_index])-avg)/avg**2)
  return volume_weighting_factor
end

# Function to create a sum of a market price (open, high, low, close) that is adjusted for both volume and time
def volumeExponentialWeightedSum(raw_data, rdcs, rdrs, price_index, time_strength, volume_index, volume_strength) #raw_data must be two-dimensional array, index must be integer
  working_data = Array.new(rdcs){Array.new(rdrs)}
  working_data = raw_data
  i = 0
  volume_exponential_weighted_sum = 0
  rdcs.times do
    volume_exponential_weighted_sum += volumeWeightingFactor(working_data, rdcs, rdrs, i, volume_index, volume_strength)*(working_data[i][price_index])*Math.exp(-(i/time_strength))
    i += 1
  end
  return volume_exponential_weighted_sum
end

# Function to create a volume and time adjusted average of a market price.
def volumeExponentialMovingAverage(raw_data, rdcs, rdrs, price_index, time_strength, volume_index, volume_strength)
  working_data = Array.new(rdcs){Array.new(rdrs)}
  working_data = raw_data
  volume_exponential_moving_average = volumeExponentialWeightedSum(working_data, rdcs, rdrs, price_index, time_strength, volume_index, volume_strength)/exponentialWeightingFactor(rdcs, time_strength)
  return volume_exponential_moving_average
end


# mar_data# is array containing unanalyzed market data from the API websocket. Its format is [timestamp, open, high, low, close, volume]
# In application this data would be retrieved from GDAX


mar_data0 = [0, 291.0, 295.0, 290.0, 292.0, 7.0]
mar_data1 = [1, 292, 295, 289, 294, 8]
mar_data2 = [2, 294, 297, 286, 289, 2]
mar_data3 = [3, 289, 292, 285, 287, 23]
mar_data4 = [4, 287, 290, 282, 288, 12]
mar_data5 = [5, 288, 295, 283, 292, 9]
mar_data6 = [6, 292, 301, 290, 297, 6]

mar_data = Array.new(){Array.new()}

mar_data = [mar_data0, mar_data1, mar_data2, mar_data3, mar_data4, mar_data5, mar_data6]


print volumeExponentialMovingAverage(mar_data, mar_data.size, mar_data[0].size, 2, 10.0, 5, 10)

print "\n\n"
