import streamlit as st
from pathlib import Path
from datetime import datetime

from agent import run_agent

st.title("Inventory Operations Copilot")

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display existing messages
for message in st.session_state.messages:    

    with st.chat_message(message["role"]):

        st.write(message["content"])

        if message["role"] == "assistant":

            diagrams = message.get("diagrams", [])

            if diagrams:

                st.subheader("Diagrams")

                for diagram in diagrams:

                    with st.expander(
                        f"{diagram['name']} ({diagram['modified']})",
                        expanded=False
                    ):
                        st.image(
                            diagram["path"],
                            caption=diagram["name"],
                            use_container_width=True
                        )

# Input box remains at bottom
question = st.chat_input("Ask a question")

if question:

    # Display user message immediately
    with st.chat_message("user"):
        st.write(question)

    st.session_state.messages.append({
        "role": "user",
        "content": question
    })

    answer = run_agent(question)

    diagram_dir = Path("../diagrams")

    png_files = sorted(
        diagram_dir.glob("*.png"),
        key=lambda p: p.stat().st_mtime,
        reverse=True
    )

    diagram_data = []

    for png_file in png_files:

        diagram_data.append({
            "name": png_file.name,
            "path": str(png_file),
            "modified": datetime.fromtimestamp(
                png_file.stat().st_mtime
            ).strftime("%Y-%m-%d %H:%M:%S")
        })

    with st.chat_message("assistant"):

        st.write(answer)

        if diagram_data:

            st.subheader("Diagrams")

            for diagram in diagram_data:

                with st.expander(
                    f"{diagram['name']} ({diagram['modified']})"
                ):
                    st.image(
                        diagram["path"],
                        caption=diagram["name"],
                        use_container_width=True
                    )

    st.session_state.messages.append({
        "role": "assistant",
        "content": answer,
        "diagrams": diagram_data
    })