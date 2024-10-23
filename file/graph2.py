import matplotlib.pyplot as plt

# Data RPS (Requests Per Second) for each algorithm
algorithms = ['1 Worker', '2 Worker', '3 Worker']
rps_values = [771, 743, 703]

# Combine algorithms and rps_values, then sort by rps_values
combined = list(zip(algorithms, rps_values))
sorted_combined = sorted(combined, key=lambda x: x[1], reverse=True)

# Unzip the sorted list back into two separate lists
sorted_algorithms, sorted_rps_values = zip(*sorted_combined)

# Create a histogram (bar chart)
plt.bar(sorted_algorithms, sorted_rps_values, color=['blue', 'green', 'red'])

# Add titles and labels
plt.title('RPS Comparison For Each Workers')
plt.xlabel('Worker')
plt.ylabel('Requests Per Second (RPS)')

# Show the plot
plt.xticks(rotation=15)
plt.tight_layout()
plt.show()
