import streamlit as st
from pathlib import Path
from datetime import datetime

from agent import run_agent

st.title("Inventory Operations Copilot")

question = st.chat_input("Ask a question")

if question:

    with st.chat_message("user"):
        st.write(question)

    answer = run_agent(question)

    with st.chat_message("assistant"):
        st.write(answer)

        diagram_dir = Path("../diagrams")

        png_files = sorted(
            diagram_dir.glob("*.png"),
            key=lambda p: p.stat().st_mtime,
            reverse=True
        )

        if png_files:

            st.subheader("Diagrams")

            for png_file in png_files:

                modified = datetime.fromtimestamp(
                    png_file.stat().st_mtime
                ).strftime("%Y-%m-%d %H:%M:%S")

                with st.expander(
                    f"{png_file.name} ({modified})",
                    expanded=False
                ):
                    st.image(
                        str(png_file),
                        caption=png_file.name,
                        use_container_width=True
                    )