#!/usr/bin/env python3

import plotly.figure_factory as ff
import pandas as pd
import argparse
import plotly.graph_objects as go
from plotly.subplots import make_subplots


def extract_genus_species(taxonomic_string):
    elements = taxonomic_string.split(';')
    genus = species = None
    for element in elements:
        if element.startswith("g__"):
            genus = element[3:]
        elif element.startswith("s__"):
            species = element[3:]
    return f"{genus} {species}" if genus and species else None

def limit_to_two_words(genus_species):
    words = genus_species.split()
    return " ".join(words[:2])

def make_taxa_table(input_file, output_file):

    # Load csv file into dataframe
    df = pd.read_csv(input_file)

    # Transpose dataframe
    df_transposed = df.transpose()

    # Reset the index for easier manipulation
    df_transposed.reset_index(inplace=True)

    # Rename the columns for clarity
    df_transposed.columns = ['Taxonomic_Classification', 'Read_Count']

    # Drop the first row as it is a placeholder ("subseq")
    df_transposed = df_transposed.drop(0)


    # Extract genus and species
    df_transposed['Genus_Species'] = df_transposed['Taxonomic_Classification'].apply(extract_genus_species)
    
    # Drop rows where Genus_Species could not be extracted (i.e., is None)
    df_transposed.dropna(subset=['Genus_Species'], inplace=True)
    
    # Extract only Genus and Species
    df_transposed['Genus_Species_Limited'] = df_transposed['Genus_Species'].apply(limit_to_two_words)

    # Convert the 'Read_Count' column to numeric for calculations
    df_transposed['Read_Count'] = pd.to_numeric(df_transposed['Read_Count'], errors='coerce')

    # Calculate the total read count
    total_read_count = df_transposed['Read_Count'].sum()

    # Calculate the relative abundance
    df_transposed['Relative_Abundance'] = df_transposed['Read_Count'] / total_read_count * 100

    # Create a list to specify which labels to show (show only species with >10% relative abundance)
    labels_to_show = [limit_to_two_words(label) if abundance > 10 else '' for label, abundance in zip(df_transposed['Genus_Species'], df_transposed['Relative_Abundance'])]

    # Adjust the pie chart size by setting its domain
    domain_pie = dict(x=[0, 1], y=[0.2, 1])  # Adjust domain to make pie chart bigger

    # Create subplots: 2 rows, 1 column again for the modified criteria
    fig = make_subplots(rows=2, cols=1, specs=[[{'type':'table'}], [{'type':'pie'}]],
                    vertical_spacing=0.2)
    
    # Add table to the first row
    fig.add_trace(go.Table(
        header=dict(values=['Species Name', 'Relative Abundance (%)'],
                    fill_color='paleturquoise',
                    align='left'),
        cells=dict(values=[df_transposed['Genus_Species_Limited'], df_transposed['Relative_Abundance'].round(1)],
                fill_color='white',
                align='left')),
        row=1, col=1)
        
    # Add pie chart to the second row with the new label criteria
    # Add pie chart with labels displayed using lines and horizontal text
    fig.add_trace(go.Pie(labels=df_transposed['Genus_Species_Limited'], values=df_transposed['Relative_Abundance'],
                        textinfo='label+percent', hole=0.4, showlegend=False, textposition='outside',
                        texttemplate=labels_to_show, domain=domain_pie),
        row=2, col=1)

    # Update layout and title
    fig.update_layout(title='<b>Pathogens Detected</b><br><br>Bacteria')
    fig.update_layout(height=1000)

    return fig

# Modify the function to generate the complete HTML file content with modern title styling
def create_complete_html_modern_title(fig_html_str, logo_base64, title="Detected Pathogens", subtitle="Taxonomic Classification: Table and Pie Chart"):
    # Create a complete HTML file content with additional title, horizontal line, and custom CSS for table width
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>{title}</title>
        <style>
            /* Custom CSS to adjust the table width */
            .js-plotly-plot .plotly .scrollbox .table {{
                width: 50% !important;
            }}
            /* Position the logo */
            #logo {{
                position: absolute;
                top: 10px;
                right: 10px;
                width: 150px;
            }}
            /* Modern title styling */
            h1, h2 {{
                font-family: 'Arial', sans-serif;
                color: #333;
                text-align: center;
            }}
            h1 {{
                font-size: 36px;
            }}
            h2 {{
                font-size: 24px;
                margin-top: -10px;
            }}
        </style>
    </head>
    <body>
        <img id="logo" src="data:image/png;base64,{logo_base64}">
        <h1>{title}</h1>
        <h2>{subtitle}</h2>
        <hr>
        {fig_html_str}
    </body>
    </html>
    """
    return html_content


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Create AMR table.')
    parser.add_argument('input_file', type=str, help='Input file name')
    parser.add_argument('output_file', type=str, help='Output file name')
    args = parser.parse_args()

    with open('./mpbio_bluegreen.png', "rb") as f:
        logo_base64 = base64.b64encode(f.read()).decode("utf-8")

    # fig = make_taxa_table(args.input_file, args.output_file)

    # # Generate the Plotly figure's HTML string without the full HTML structure, but with Plotly.js included from a CDN
    # fig_html_str = fig.to_html(full_html=False, include_plotlyjs='cdn')

    # # Generate the complete HTML content using the modified function
    # html_content_modern_title = create_complete_html_modern_title(fig_html_str, logo_base64)

    # # Save the complete HTML file with the modern title styling
    # output_html_modern_title = './output_modern_title.html'
    # with open(output_html_modern_title, 'w') as f:
    #     f.write(html_content_modern_title)

